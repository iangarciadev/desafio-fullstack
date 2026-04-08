import axios from 'axios'

// Instância do axios configurada com a URL base da API definida em VITE_API_URL.
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL
})

// Interceptor que injeta o token JWT no header Authorization de todas as requisições.
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export default api