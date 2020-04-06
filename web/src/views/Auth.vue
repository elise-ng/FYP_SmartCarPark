<template>
  <div>
    <el-form v-if="!user">
      <el-form-item label="Email">
        <el-input v-model="email"></el-input>
      </el-form-item>
      <el-form-item label="Password">
        <el-input v-model="password" show-password></el-input>
      </el-form-item>
      <el-button type="primary" @click="submitLogin">Login</el-button>
    </el-form>

    <el-form v-if="user">
      <el-form-item label="Logged in as">
        <div class="form-field-plaintext">{{ this.user.email }}</div>
      </el-form-item>
      <el-button type="danger" @click="submitLogout" style="margin-left:8px;">Logout</el-button>
    </el-form>
  </div>
</template>

<script>
import { auth } from '@/helpers/firebaseHelper'
export default {
  name: 'Auth',
  data () {
    return {
      user: null,
      email: '',
      password: ''
    }
  },
  methods: {
    async submitLogin () {
      try {
        await auth.signInWithEmailAndPassword(this.email, this.password)
        this.user = auth.currentUser
      } catch (e) {
        this.$message.error(e.message || e.toString())
      }
    },
    async submitLogout () {
      try {
        await auth.signOut()
        this.user = auth.currentUser
      } catch (e) {
        this.$message.error(e.message || e.toString())
      }
    }
  },
  mounted () {
    this.user = auth.currentUser
  }
}
</script>
