import { Request, Response } from 'express'
import prisma from '../../prisma'

export async function createTask(req: Request, res: Response) {
  const { title, description, clientId } = req.body

  const task = await prisma.task.create({
    data: { title, description, clientId: Number(clientId) }
  })

  return res.status(201).json(task)
}

export async function getTasks(req: Request, res: Response) {
  const { status, clientId } = req.query

  const tasks = await prisma.task.findMany({
    where: {
      ...(status && { status: String(status) as any }),
      ...(clientId && { clientId: Number(clientId) })
    },
    include: { client: true }
  })

  return res.json(tasks)
}

export async function updateTask(req: Request, res: Response) {
  const { id } = req.params
  const { title, description, status } = req.body

  const task = await prisma.task.update({
    where: { id: Number(id) },
    data: { title, description, status }
  })

  return res.json(task)
}

export async function deleteTask(req: Request, res: Response) {
  const { id } = req.params

  await prisma.task.delete({
    where: { id: Number(id) }
  })

  return res.status(204).send()
}