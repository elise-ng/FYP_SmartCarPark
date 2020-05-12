<template>
  <div id="app">
    <el-container style="height: 100%;">
      <el-aside width="200px">
        <el-menu :router="true" style="height: 100%;">
          <el-main>🚙 Smart Car Park</el-main>
          <el-menu-item index="/live">
              <i class="el-icon-monitor"></i>
              <span slot="title">Live View</span>
          </el-menu-item>
          <el-menu-item index="/stats">
              <i class="el-icon-data-analysis"></i>
              <span slot="title">Statistics</span>
          </el-menu-item>
          <el-menu-item index="/demo">
              <i class="el-icon-magic-stick"></i>
              <span slot="title">Demo</span>
          </el-menu-item>
          <el-menu-item index="/auth" style="position:absolute; bottom:0; width:100%;">
              <i class="el-icon-key"></i>
              <span slot="title">Authenication</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main>
        <router-view/>
      </el-main>
    </el-container>
  </div>
</template>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: left;
  color: #2c3e50;
  height: 100%;
}

html, body {
  height: 100%;
  overflow: hidden;
}
</style>
