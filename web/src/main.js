import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import App from './App.vue'

import { createRouter, createWebHashHistory } from 'vue-router'

const routes = [
    { path: '/', component: () => import('@/views/coregame/index') },
    { path: '/compound', component: () => import('@/views/compound/index') },
    { path: '/market', component: () => import('@/views/market/index') },
    { path: '/user', component: () => import('@/views/user/index') },
]

const router = createRouter({
    history: createWebHashHistory(),
    routes,
})

const app = createApp(App)

app.use(router)
app.use(ElementPlus)
app.mount('#app')
