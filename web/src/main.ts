import Vue from 'vue'
import App from './App.vue'
import router from './router'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import { firestorePlugin } from 'vuefire'

Vue.config.productionTip = false

Vue.use(ElementUI)
Vue.use(firestorePlugin)

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')
