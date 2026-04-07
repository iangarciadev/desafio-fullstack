import { Request, Response } from 'express'
import prisma from '../../prisma'

export async function createClient(req: Request, res: Response) {
  const { name, email } = req.body

  const client = await prisma.client.create({
    data: { name, email, userId: req.userId }
  })

  return res.status(201).json(client)
}

export async function getClients(req: Request, res: Response) {
  const clients = await prisma.client.findMany({
    where: { userId: req.userId }
  })

  return res.json(clients)
}

export async function updateClient(req: Request, res: Response) {
  const { id } = req.params
  const { name, email } = req.body

  const client = await prisma.client.update({
    where: { id: Number(id) },
    data: { name, email }
  })

  return res.json(client)
}

export async function deleteClient(req: Request, res: Response) {
  const { id } = req.params

  await prisma.client.delete({
    where: { id: Number(id) }
  })

  return res.status(204).send()
}