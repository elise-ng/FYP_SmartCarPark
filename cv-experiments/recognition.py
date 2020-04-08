from imutils.object_detection import non_max_suppression
from skimage.filters import threshold_minimum
from sklearn.cluster import KMeans
import pytesseract
import matplotlib.pyplot as plt
import numpy as np
import cv2
import time
import math


# %%
start_time = time.time()
src = cv2.imread("./images/3.png")
src = cv2.cvtColor(src, cv2.COLOR_RGB2BGR)


# %%
(H, W) = src.shape[:2]

x_offset = W % 32
y_offset = H % 32
new_x_start = math.floor(x_offset / 2)
new_x_end = W - math.ceil(x_offset / 2)
new_y_start = math.floor(y_offset / 2)
new_y_end = H - math.ceil(y_offset / 2)

src = src[new_y_start:new_y_end, new_x_start:new_x_end]
orig = src.copy()
(H, W) = src.shape[:2]


# %%
layers = ["feature_fusion/Conv_7/Sigmoid", "feature_fusion/concat_3"]
net = cv2.dnn.readNet("frozen_east_text_detection.pb")

blob = cv2.dnn.blobFromImage(src, 1.0, (W, H),
	(127, 127, 127), swapRB=False, crop=False)
net.setInput(blob)
(scores, geometry) = net.forward(layers)


# %%
(numRows, numCols) = scores.shape[2:4]
rects = []
confidences = []
for y in range(0, numRows):
	scoresData = scores[0, 0, y]
	xData0 = geometry[0, 0, y]
	xData1 = geometry[0, 1, y]
	xData2 = geometry[0, 2, y]
	xData3 = geometry[0, 3, y]
	anglesData = geometry[0, 4, y]

	for x in range(0, numCols):
		# Ignore low probability predictions
		if scoresData[x] < 0.5:
			continue
		(offsetX, offsetY) = (x * 4.0, y * 4.0)
		angle = anglesData[x]
		cos = np.cos(angle)
		sin = np.sin(angle)
		h = xData0[x] + xData2[x]
		w = xData1[x] + xData3[x]
		if h * w < 1000:
			continue
		endX = int(offsetX + (cos * xData1[x]) + (sin * xData2[x]))
		endY = int(offsetY - (sin * xData1[x]) + (cos * xData2[x]))
		startX = int(endX - w)
		startY = int(endY - h)
		rects.append((startX, startY, endX, endY))
		confidences.append(scoresData[x])

boxes = non_max_suppression(np.array(rects), probs=confidences)
demo = orig.copy()
points = []
for (startX, startY, endX, endY) in boxes:
	cv2.rectangle(demo, (startX, startY), (endX, endY), (0, 255, 0), 2)
	points.append((startX, startY))
	points.append((endX, endY))
plt.imshow(demo)
plt.show()


# %%
rect = cv2.boundingRect(np.array(points))
x,y,w,h = rect
rect_demo = orig.copy()
cv2.rectangle(rect_demo, (x, y), (x+w, y+h), (0,255,0), 2)
plt.imshow(rect_demo)
plt.show()


# %%
dilate_offset = 0
plate = orig[max(y-dilate_offset, 0):min(y+h+dilate_offset, H), max(x-dilate_offset, 0):min(x+w+dilate_offset, W)]
plt.imshow(plate)
plt.show()


# %%
plate_hsv= cv2.cvtColor(plate.copy(), cv2.COLOR_BGR2HSV)
plate_color = plate_hsv.reshape((plate_hsv.shape[0] * plate_hsv.shape[1], 3))
clt = KMeans(n_clusters = 2)
clt.fit(plate_color)
color = clt.cluster_centers_.astype(int)[np.argmax(np.bincount(clt.labels_))]

# Yello threshold
lower_yellow = np.array([70, 50, 100])
upper_yellow = np.array([110, 255, 255])
# White threshold
lower_white = np.array([0, 0, 80])
upper_white = np.array([179, 70, 255])

in_range = False
lower_color = 0
upper_color = 0

if all(color > lower_yellow) and all(color < upper_yellow):
    in_range = True
    lower_color = lower_yellow
    upper_color = upper_yellow
elif all(color > lower_white) and all(color < upper_white):
    in_range = True
    lower_color = lower_white
    upper_color = upper_white

if in_range:   
    img_color_thres_mask = cv2.inRange(plate_hsv, lower_color, upper_color)
    plate = cv2.cvtColor(cv2.bitwise_and(plate_hsv, plate_hsv, mask=img_color_thres_mask), cv2.COLOR_HSV2BGR)

plt.imshow(plate)
plt.show()


# %%
gray_plate = cv2.cvtColor(plate, cv2.COLOR_BGR2GRAY)
threshold = threshold_minimum(gray_plate)
binary_plate = (gray_plate > threshold).astype(np.uint8)
# kernel = cv2.copyMakeBorder(binary_plate, 1, 1, 1, 1, cv2.BORDER_CONSTANT, 0)
# cv2.floodFill(binary_plate, kernel, (5, 5), 255)
# binary_plate = kernel
plt.imshow(binary_plate, cmap = 'gray')
plt.show()


# %%
license = ''.join(pytesseract.image_to_string(binary_plate, lang='eng', config='-c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 --psm 6').split())
print(license)


# %%
end_time = time.time()
print("Plate detection took {:.6f} seconds".format(end_time - start_time))

