export interface Client {
  id: number
  name: string
  email: string
}

export interface Task {
  id: number
  title: string
  status: string
  client: { name: string }
}
