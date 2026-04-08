<template>
  <div>
    <div class="page-header">
      <h1>Tarefas</h1>
      <span class="count">{{ tasks.length }} tarefa{{ tasks.length !== 1 ? 's' : '' }}</span>
    </div>

    <div class="card form-card">
      <h2>Nova tarefa</h2>
      <form @submit.prevent="handleCreate" class="form-grid">
        <div class="form-field">
          <label for="title">Título</label>
          <input id="title" v-model="title" class="input" placeholder="Ex: Criar proposta" required />
        </div>
        <div class="form-field">
          <label for="description">Descrição</label>
          <input id="description" v-model="description" class="input" placeholder="Opcional" />
        </div>
        <div class="form-field">
          <label for="client">Cliente</label>
          <select id="client" v-model="clientId" class="input" required>
            <option :value="null" disabled>Selecione um cliente</option>
            <option v-for="client in clients" :key="client.id" :value="client.id">
              {{ client.name }}
            </option>
          </select>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Adicionar</button>
        </div>
      </form>
      <p v-if="error" class="error-msg">{{ error }}</p>
    </div>

    <div class="card">
      <div class="list-header">
        <h2>Lista de tarefas</h2>
        <select v-model="statusFilter" class="input filter-select" @change="fetchTasks">
          <option value="">Todos os status</option>
          <option value="PENDING">Pendente</option>
          <option value="IN_PROGRESS">Em andamento</option>
          <option value="DONE">Concluído</option>
        </select>
      </div>

      <div v-if="tasks.length === 0" class="empty-state">
        Nenhuma tarefa encontrada.
      </div>
      <ul v-else class="task-list">
        <li v-for="task in tasks" :key="task.id" class="task-item">
          <div class="task-main">
            <span class="task-title">{{ task.title }}</span>
            <span class="task-client">{{ task.client.name }}</span>
          </div>
          <div class="task-side">
            <span :class="statusBadgeClass(task.status)" class="badge">{{ statusLabel(task.status) }}</span>
            <select :value="task.status" class="input status-select" @change="handleUpdateStatus(task, ($event.target as HTMLSelectElement).value)">
              <option value="PENDING">Pendente</option>
              <option value="IN_PROGRESS">Em andamento</option>
              <option value="DONE">Concluído</option>
            </select>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../services/api'
import type { Client, Task } from '../types'

const tasks = ref<Task[]>([])
const clients = ref<Client[]>([])
const title = ref('')
const description = ref('')
const clientId = ref<number | null>(null)
const statusFilter = ref('')
const error = ref('')

// Converte o status interno da tarefa para o rótulo em português exibido na interface.
function statusLabel(status: string) {
  const map: Record<string, string> = {
    PENDING: 'Pendente',
    IN_PROGRESS: 'Em andamento',
    DONE: 'Concluído'
  }
  return map[status] ?? status
}

// Retorna o objeto de classes CSS para colorir o badge de acordo com o status da tarefa.
function statusBadgeClass(status: string) {
  return {
    'badge-pending': status === 'PENDING',
    'badge-in-progress': status === 'IN_PROGRESS',
    'badge-done': status === 'DONE'
  }
}

// Busca as tarefas do usuário autenticado via GET /tasks.
// Aplica o filtro de status como query param caso esteja selecionado.
async function fetchTasks() {
  try {
    const params: Record<string, string> = {}
    if (statusFilter.value) params.status = statusFilter.value
    const response = await api.get('/tasks', { params })
    tasks.value = response.data
  } catch {
    error.value = 'Erro ao carregar tarefas. Tente novamente.'
  }
}

// Busca todos os clientes via GET /clients para popular o dropdown de seleção no formulário.
async function fetchClients() {
  try {
    const response = await api.get('/clients')
    clients.value = response.data
  } catch {
    error.value = 'Erro ao carregar clientes. Tente novamente.'
  }
}

// Cria uma nova tarefa via POST /tasks com título, descrição e clientId.
// Limpa o formulário e atualiza a lista de tarefas após a criação.
async function handleCreate() {
  if (!clientId.value) return
  error.value = ''
  try {
    await api.post('/tasks', {
      title: title.value,
      description: description.value,
      clientId: clientId.value
    })
    title.value = ''
    description.value = ''
    clientId.value = null
    await fetchTasks()
  } catch {
    error.value = 'Erro ao adicionar tarefa. Tente novamente.'
  }
}

// Atualiza o status de uma tarefa via PUT /tasks/:id com o novo valor selecionado.
// O estado local só é atualizado após a confirmação da API via fetchTasks().
async function handleUpdateStatus(task: Task, newStatus: string) {
  error.value = ''
  try {
    await api.put(`/tasks/${task.id}`, { status: newStatus })
    await fetchTasks()
  } catch {
    error.value = 'Erro ao atualizar o status. Tente novamente.'
  }
}

// Carrega as tarefas e os clientes ao montar o componente.
onMounted(() => {
  fetchTasks()
  fetchClients()
})
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

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr auto;
  gap: 1rem;
  align-items: flex-end;
}

.form-actions {
  display: flex;
  align-items: flex-end;
}

.list-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.filter-select {
  width: auto;
  min-width: 160px;
}

.empty-state {
  text-align: center;
  color: var(--color-text-muted);
  padding: 2rem 0;
  font-size: 0.9rem;
}

.task-list {
  list-style: none;
  display: flex;
  flex-direction: column;
}

.task-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.85rem 0;
  border-bottom: 1px solid var(--color-border);
  gap: 1rem;
}

.task-item:last-child {
  border-bottom: none;
}

.task-main {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
  min-width: 0;
}

.task-title {
  font-weight: 600;
  font-size: 0.95rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.task-client {
  font-size: 0.82rem;
  color: var(--color-text-muted);
}

.task-side {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-shrink: 0;
}

.status-select {
  width: auto;
  font-size: 0.85rem;
  padding: 0.35rem 0.6rem;
}
</style>
