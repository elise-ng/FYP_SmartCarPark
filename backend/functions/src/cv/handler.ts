import * as functions from 'firebase-functions'
import * as vision from '@google-cloud/vision';

const visionClient = new vision.ImageAnnotatorClient();

function intersects(a, b) {
    var polygons = [a, b];
    var minA, maxA, projected, i, i1, j, minB, maxB;

    for (i = 0; i < polygons.length; i++) {

        // for each polygon, look at each edge of the polygon, and determine if it separates
        // the two shapes
        var polygon = polygons[i];
        for (i1 = 0; i1 < polygon.length; i1++) {

            // grab 2 vertices to create an edge
            var i2 = (i1 + 1) % polygon.length;
            var p1 = polygon[i1];
            var p2 = polygon[i2];

            // find the line perpendicular to this edge
            var normal = { x: p2.y - p1.y, y: p1.x - p2.x };

            minA = maxA = undefined;
            // for each vertex in the first shape, project it onto the line perpendicular to the edge
            // and keep track of the min and max of these values
            for (j = 0; j < a.length; j++) {
                projected = normal.x * a[j].x + normal.y * a[j].y;
                if (!minA || projected < minA) {
                    minA = projected;
                }
                if (!maxA || projected > maxA) {
                    maxA = projected;
                }
            }

            // for each vertex in the second shape, project it onto the line perpendicular to the edge
            // and keep track of the min and max of these values
            minB = maxB = undefined;
            for (j = 0; j < b.length; j++) {
                projected = normal.x * b[j].x + normal.y * b[j].y;
                if (!minB || projected < minB) {
                    minB = projected;
                }
                if (!maxB || projected > maxB) {
                    maxB = projected;
                }
            }

            // if there is no overlap between the projects, the edge we are looking at separates the two
            // polygons, and we know there is no overlap
            if (maxA < minB || maxB < minA) {
                return false;
            }
        }
    }
    return true;
}

function buildTextObject(words) {
    let textArray: string[] = []
    let text = ""
    for (let word of words) {
        text += word.symbols.map(symbol => symbol.text).join("")
        let lastSymbol = word.symbols[word.symbols.length - 1]
        if ('property' in lastSymbol && 'detectedBreak' in lastSymbol.property && lastSymbol.property.detectedBreak) {
            let type = lastSymbol.property.detectedBreak.type
            if (type === "EOL_SURE_SPACE" || type === "LINE_BREAK") {
                textArray.push(text)
                text = ""
            }
        }
    }
    return textArray.map((text) => (text.match(/[a-zA-Z0-9粵港]+/g) || []).join('')) // Filter out undesired character
}

function getBoundingBoxArea(vertices) {
    return (vertices[2].x - vertices[0].x) * (vertices[2].y - vertices[0].y)
} 

export const recognizeLicensePlate = functions
    .region('asia-east2')
    .https
    .onCall(async (data, _) => { // eslint-disable-line no-unused-vars
        interface Parameters {
            imageGsPath: string,
        }

        // parse params
        const params = data as Parameters
        if (!params.imageGsPath) {
            throw new functions.https.HttpsError('invalid-argument', 'parameter missing')
        }

        const annotateRequest = {
            image: {
                source: {
                    imageUri: params.imageGsPath
                }
            },
            features: [
                {
                    type: "OBJECT_LOCALIZATION"
                },
                {
                    type: "TEXT_DETECTION"
                },
            ],
            imageContext: {
                languageHints: ["en", "zh-Hant-HK"]
            }
        }

        let [annotateResponse] = await visionClient.annotateImage(annotateRequest)
        let fullTextAnnotation = annotateResponse.fullTextAnnotation
        let page = fullTextAnnotation.pages[0]
        let blocks = page.blocks.sort((a, b) => getBoundingBoxArea(b.boundingBox.vertices) - getBoundingBoxArea(a.boundingBox.vertices)) // Sort bounding box in decending order w.r.t. area
        let width = page.width
        let height = page.height

        let objectAnnotations = annotateResponse.localizedObjectAnnotations
        let licensePlateObjects = objectAnnotations.filter(object => object.mid === '/m/01jfm_') // Filter only license plate object
        let texts: string[] = []

        for (let element of licensePlateObjects) {
            let objectVertices = element.boundingPoly.normalizedVertices.map(coord => ({ x: Math.round(coord.x * width), y: Math.round(coord.y * height) }))
            for (let textBlock of blocks) {
                if (intersects(objectVertices, textBlock.boundingBox.vertices)) {
                    texts = buildTextObject(textBlock.paragraphs[0].words)
                    break
                }
            }
        }

        if (!licensePlateObjects.length || !texts) {
            // If license plate object is not found, or no valid text blocks are identified
            return {
                success: true,
                license: (fullTextAnnotation.text.match(/[a-zA-Z0-9粵港]+/g) || []).join('')
            }
        }

        let mainlandLicense
        let chinaHKLicenseIndex = texts.findIndex(text => text.includes('粵') || text.includes('港'))
        if (chinaHKLicenseIndex > -1) {
            mainlandLicense = `粵${(texts.splice(chinaHKLicenseIndex, 1)[0].match(/[a-zA-Z0-9]+/g) || []).join('')}港` // Reformat mainland license just in case
        }

        let license = texts.join('')

        if (mainlandLicense) {
            return {
                success: true,
                license: license,
                mainlandLicense: mainlandLicense
            }
        } else {
            return {
                success: true,
                license: license
            }
        }
    })