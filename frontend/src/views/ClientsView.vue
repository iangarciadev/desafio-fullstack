<template>
  <div>
    <div class="page-header">
      <h1>Clientes</h1>
      <span class="count">{{ clients.length }} cadastrado{{ clients.length !== 1 ? 's' : '' }}</span>
    </div>

    <div class="card form-card">
      <h2>Adicionar cliente</h2>
      <form @submit.prevent="handleCreate" class="form-row">
        <div class="form-field">
          <label for="name">Nome</label>
          <input id="name" v-model="name" class="input" placeholder="Nome completo" required />
        </div>
        <div class="form-field">
          <label for="email">Email</label>
          <input id="email" v-model="email" class="input" type="email" placeholder="email@exemplo.com" required />
        </div>
        <button type="submit" class="btn btn-primary btn-add">Adicionar</button>
      </form>
      <p v-if="error" class="error-msg">{{ error }}</p>
    </div>

    <div class="card">
      <div v-if="clients.length === 0" class="empty-state">
        Nenhum cliente cadastrado ainda.
      </div>
      <ul v-else class="client-list">
        <li v-for="client in clients" :key="client.id" class="client-item">
          <div class="client-avatar">{{ client.name[0]?.toUpperCase() ?? '?' }}</div>
          <div class="client-info">
            <span class="client-name">{{ client.name }}</span>
            <span class="client-email">{{ client.email }}</span>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../services/api'
import type { Client } from '../types'

const clients = ref<Client[]>([])
const name = ref('')
const email = ref('')
const error = ref('')

// Busca todos os clientes do usuário autenticado via GET /clients e popula a lista.
async function fetchClients() {
  try {
    const response = await api.get('/clients')
    clients.value = response.data
  } catch {
    error.value = 'Erro ao carregar clientes. Tente novamente.'
  }
}

// Cria um novo cliente via POST /clients com nome e email, limpa o formulário e atualiza a lista.
async function handleCreate() {
  error.value = ''
  try {
    await api.post('/clients', { name: name.value, email: email.value })
    name.value = ''
    email.value = ''
    await fetchClients()
  } catch {
    error.value = 'Erro ao adicionar cliente. Tente novamente.'
  }
}

// Carrega a lista de clientes ao montar o componente.
onMounted(fetchClients)
</script>

<style scoped>
.page-header {
  display: flex;
  align-items: baseline;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.count {
  font-size: 0.85rem;
  color: var(--color-text-muted);
}

.form-card {
  margin-bottom: 1.5rem;
}

.form-card h2 {
  margin-bottom: 1rem;
}

.form-row {
  display: flex;
  gap: 1rem;
  align-items: flex-end;
}

.form-row .form-field {
  flex: 1;
}

.btn-add {
  white-space: nowrap;
  height: 38px;
}

.empty-state {
  text-align: center;
  color: var(--color-text-muted);
  padding: 2rem 0;
  font-size: 0.9rem;
}

.client-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 0;
}

.client-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.85rem 0;
  border-bottom: 1px solid var(--color-border);
}

.client-item:last-child {
  border-bottom: none;
}

.client-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: var(--color-primary);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  font-weight: 700;
  flex-shrink: 0;
}

.client-info {
  display: flex;
  flex-direction: column;
  gap: 0.1rem;
}

.client-name {
  font-weight: 600;
  font-size: 0.95rem;
}

.client-email {
  font-size: 0.82rem;
  color: var(--color-text-muted);
}
</style>
