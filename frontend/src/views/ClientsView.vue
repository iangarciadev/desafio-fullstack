<template>
  <div>
    <div class="page-header">
      <h1>Clientes</h1>
      <span class="count">{{ clients.length }} cadastrado{{ clients.length !== 1 ? 's' : '' }}</span>
    </div>

    <div class="card form-card">
      <h2>Adicionar cliente</h2>
      <form @submit.prevent="handleCreate">
        <div class="form-row">
          <div class="form-field">
            <label for="name">Nome</label>
            <input id="name" v-model="name" class="input" placeholder="Nome completo" required />
          </div>
          <div class="form-field">
            <label for="email">Email</label>
            <input id="email" v-model="email" class="input" type="email" placeholder="email@exemplo.com" required />
          </div>
        </div>
        <div class="form-row">
          <div class="form-field form-field--cep">
            <label for="cep">CEP</label>
            <input
              id="cep"
              v-model="cep"
              class="input"
              placeholder="00000-000"
              maxlength="9"
              @input="onCepInput"
            />
          </div>
          <div class="form-field form-field--grow">
            <label for="logradouro">Logradouro</label>
            <input id="logradouro" v-model="logradouro" class="input" placeholder="Preenchido pelo CEP" :readonly="cepPreenchido" />
          </div>
          <div class="form-field form-field--numero">
            <label for="numero">Número</label>
            <input id="numero" v-model="numero" class="input" placeholder="Nº" />
          </div>
        </div>
        <div class="form-row">
          <div class="form-field">
            <label for="complemento">Complemento</label>
            <input id="complemento" v-model="complemento" class="input" placeholder="Apto, sala..." />
          </div>
          <div class="form-field">
            <label for="bairro">Bairro</label>
            <input id="bairro" v-model="bairro" class="input" placeholder="Preenchido pelo CEP" :readonly="cepPreenchido" />
          </div>
          <div class="form-field">
            <label for="cidade">Cidade</label>
            <input id="cidade" v-model="cidade" class="input" placeholder="Preenchido pelo CEP" :readonly="cepPreenchido" />
          </div>
          <div class="form-field form-field--estado">
            <label for="estado">UF</label>
            <input id="estado" v-model="estado" class="input" placeholder="UF" :readonly="cepPreenchido" />
          </div>
        </div>
        <p v-if="cepError" class="error-msg">{{ cepError }}</p>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Adicionar</button>
        </div>
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
            <span v-if="client.logradouro" class="client-address">
              {{ client.logradouro }}{{ client.numero ? ', ' + client.numero : '' }}{{ client.complemento ? ' - ' + client.complemento : '' }} — {{ client.bairro }}, {{ client.cidade }}/{{ client.estado }}
            </span>
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
const cep = ref('')
const logradouro = ref('')
const numero = ref('')
const complemento = ref('')
const bairro = ref('')
const cidade = ref('')
const estado = ref('')
const cepPreenchido = ref(false)
const error = ref('')
const cepError = ref('')

// Busca todos os clientes do usuário autenticado via GET /clients e popula a lista.
async function fetchClients() {
  try {
    const response = await api.get('/clients')
    clients.value = response.data
  } catch {
    error.value = 'Erro ao carregar clientes. Tente novamente.'
  }
}

// Aplica máscara xxxxx-xxx ao CEP e chama ViaCEP ao completar 8 dígitos.
async function onCepInput(event: Event) {
  const input = event.target as HTMLInputElement
  let digits = input.value.replace(/\D/g, '').slice(0, 8)
  cep.value = digits.length > 5 ? `${digits.slice(0, 5)}-${digits.slice(5)}` : digits
  cepError.value = ''

  if (digits.length === 8) {
    try {
      const res = await fetch(`https://viacep.com.br/ws/${digits}/json/`)
      const data = await res.json()
      if (data.erro) {
        cepError.value = 'CEP não encontrado.'
        cepPreenchido.value = false
      } else {
        logradouro.value = data.logradouro ?? ''
        bairro.value = data.bairro ?? ''
        cidade.value = data.localidade ?? ''
        estado.value = data.uf ?? ''
        cepPreenchido.value = true
      }
    } catch {
      cepError.value = 'Erro ao buscar CEP. Tente novamente.'
    }
  } else {
    cepPreenchido.value = false
  }
}

// Cria um novo cliente via POST /clients com nome, email e endereço, limpa o formulário e atualiza a lista.
async function handleCreate() {
  error.value = ''
  try {
    await api.post('/clients', {
      name: name.value,
      email: email.value,
      cep: cep.value || undefined,
      logradouro: logradouro.value || undefined,
      numero: numero.value || undefined,
      complemento: complemento.value || undefined,
      bairro: bairro.value || undefined,
      cidade: cidade.value || undefined,
      estado: estado.value || undefined,
    })
    name.value = ''
    email.value = ''
    cep.value = ''
    logradouro.value = ''
    numero.value = ''
    complemento.value = ''
    bairro.value = ''
    cidade.value = ''
    estado.value = ''
    cepPreenchido.value = false
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
  margin-bottom: 0.75rem;
  flex-wrap: wrap;
}

.form-row .form-field {
  flex: 1;
  min-width: 140px;
}

.form-field--cep {
  flex: 0 0 120px !important;
  min-width: 120px !important;
}

.form-field--numero {
  flex: 0 0 90px !important;
  min-width: 90px !important;
}

.form-field--estado {
  flex: 0 0 70px !important;
  min-width: 70px !important;
}

.form-field--grow {
  flex: 2 !important;
}

.form-actions {
  margin-top: 0.5rem;
  display: flex;
  justify-content: flex-end;
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

.client-address {
  font-size: 0.78rem;
  color: var(--color-text-muted);
}
</style>
