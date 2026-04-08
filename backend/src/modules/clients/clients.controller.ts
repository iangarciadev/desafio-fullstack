import { Request, Response } from 'express'
import prisma from '../../prisma'

// Cria um novo cliente vinculado ao usuário autenticado.
export async function createClient(req: Request, res: Response) {
  const { name, email, cep, logradouro, numero, complemento, bairro, cidade, estado } = req.body

  const client = await prisma.client.create({
    data: { name, email, cep, logradouro, numero, complemento, bairro, cidade, estado, userId: req.userId }
  })

  return res.status(201).json(client)
}

// Retorna todos os clientes que pertencem ao usuário autenticado.
export async function getClients(req: Request, res: Response) {
  const clients = await prisma.client.findMany({
    where: { userId: req.userId }
  })

  return res.json(clients)
}

// Atualiza nome e/ou e-mail de um cliente pelo seu id.
export async function updateClient(req: Request, res: Response) {
  const { id } = req.params
  const { name, email, cep, logradouro, numero, complemento, bairro, cidade, estado } = req.body

  const client = await prisma.client.findUnique({ where: { id: Number(id) } })

  if (!client) return res.status(404).json({ error: 'Cliente não encontrado' })
  if (client.userId !== req.userId) return res.status(403).json({ error: 'Acesso negado' })

  const updated = await prisma.client.update({
    where: { id: Number(id) },
    data: { name, email, cep, logradouro, numero, complemento, bairro, cidade, estado }
  })

  return res.json(updated)
}

// Remove um cliente pelo id. Responde com 204 (sem corpo) em caso de sucesso.
export async function deleteClient(req: Request, res: Response) {
  const { id } = req.params

  const client = await prisma.client.findUnique({ where: { id: Number(id) } })

  if (!client) return res.status(404).json({ error: 'Cliente não encontrado' })

  if (client.userId !== req.userId) return res.status(403).json({ error: 'Acesso negado' })

  await prisma.client.delete({ where: { id: Number(id) } })

  return res.status(204).send()
}