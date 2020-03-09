import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/live',
    alias: '/',
    name: 'Live View',
    component: () => import(/* webpackChunkName: "live" */ '../views/Live.vue')
  },
  {
    path: '/stats',
    name: 'Statistics',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "stats" */ '../views/Stats.vue')
  }
]

const router = new VueRouter({
  routes
})

export default router
