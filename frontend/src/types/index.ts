export interface Client {
  id: number
  name: string
  email: string
  cep?: string
  logradouro?: string
  numero?: string
  complemento?: string
  bairro?: string
  cidade?: string
  estado?: string
}

export interface Task {
  id: number
  title: string
  status: string
  client: { name: string }
}
