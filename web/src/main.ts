import Vue from 'vue'
import App from './App.vue'
import router from './router'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import locale from 'element-ui/lib/locale/lang/en'
import { firestorePlugin } from 'vuefire'
import VueLayers from 'vuelayers'
import 'vuelayers/lib/style.css'
import AsyncComputed from 'vue-async-computed'

Vue.config.productionTip = false

Vue.use(ElementUI, { locale })
Vue.use(firestorePlugin)
Vue.use(VueLayers)
Vue.use(AsyncComputed)

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')
