import Vue from 'vue'
import VueRouter from 'vue-router'
import { auth } from '@/helpers/firebaseHelper'

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
  },
  {
    path: '/demo',
    name: 'Demo',
    meta: { title: 'Demo' },
    component: () => import(/* webpackChunkName: "gateRecordEdit" */ '../views/Demo.vue')
  },
  {
    path: '/licensePlateRecognition/',
    name: 'LicensePlateRecognition',
    meta: { title: 'License Plate Recognition' },
    component: () => import(/* webpackChunkName: "gateRecordEdit" */ '../views/LicensePlateRecognition.vue')
  },
  {
    path: '/recognitionDemo/',
    name: 'RecognitionDemo',
    meta: { title: 'Recognition Demo' },
    component: () => import(/* webpackChunkName: "gateRecordEdit" */ '../views/RecognitionDemo.vue')
  }
]

const router = new VueRouter({
  routes
})

router.beforeEach((to, from, next) => {
  if (to.name !== 'Auth' && !auth.currentUser) {
    next({ name: 'Auth' })
  } else {
    next()
  }
})

export default router
