import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const routes = [
  {
    path: '/live',
    alias: '/',
    name: 'Live',
    meta: { title: 'Live View' },
    component: () => import(/* webpackChunkName: "live" */ '../views/Live.vue')
  },
  {
    path: '/stats',
    name: 'Stats',
    meta: { title: 'Statistics' },
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "stats" */ '../views/Stats.vue')
  },
  {
    path: '/gateRecord/:gateRecordId',
    name: 'GateRecordEdit',
    meta: { title: 'Edit Gate Record' },
    component: () => import(/* webpackChunkName: "gateRecordEdit" */ '../views/GateRecordEdit.vue')
  },
  {
    path: '/auth',
    name: 'Auth',
    meta: { title: 'Authenicate' },
    component: () => import(/* webpackChunkName: "gateRecordEdit" */ '../views/Auth.vue')
  }
]

const router = new VueRouter({
  routes
})

export default router
