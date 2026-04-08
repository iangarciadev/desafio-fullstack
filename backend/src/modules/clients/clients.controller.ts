import { Request, Response } from 'express'
import { z } from 'zod'
import prisma from '../../prisma'

const clientSchema = z.object({
  name: z.string().min(1, { message: 'Nome obrigatório' }).max(100),
  email: z.string().email({ message: 'E-mail inválido' }),
  cep: z.string().regex(/^\d{8}$/, { message: 'CEP deve conter 8 dígitos numéricos' }).optional(),
  logradouro: z.string().max(200).optional(),
  numero: z.string().max(20).optional(),
  complemento: z.string().max(100).optional(),
  bairro: z.string().max(100).optional(),
  cidade: z.string().max(100).optional(),
  estado: z.string().length(2, { message: 'Estado deve ter 2 caracteres' }).optional(),
})

const updateClientSchema = clientSchema.partial()

// Cria um novo cliente vinculado ao usuário autenticado.
export async function createClient(req: Request, res: Response) {
  const parsed = clientSchema.safeParse(req.body)
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.issues[0].message })
  }

  const client = await prisma.client.create({
    data: { ...parsed.data, userId: req.userId }
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

  const parsed = updateClientSchema.safeParse(req.body)
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.issues[0].message })
  }

  const client = await prisma.client.findUnique({ where: { id: Number(id) } })

  if (!client) return res.status(404).json({ error: 'Cliente não encontrado' })
  if (client.userId !== req.userId) return res.status(403).json({ error: 'Acesso negado' })

  const updated = await prisma.client.update({
    where: { id: Number(id) },
    data: parsed.data
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
