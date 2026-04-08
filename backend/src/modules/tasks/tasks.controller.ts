import { Request, Response } from 'express'
import { z } from 'zod'
import prisma from '../../prisma'
import logger from '../../logger'

const taskStatusEnum = z.enum(['PENDING', 'IN_PROGRESS', 'DONE'])

const createTaskSchema = z.object({
  title: z.string().min(1, { message: 'Título obrigatório' }).max(200),
  description: z.string().max(1000).optional(),
  clientId: z.number({ message: 'clientId deve ser um número' }).int().positive(),
})

const updateTaskSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  description: z.string().max(1000).optional(),
  status: taskStatusEnum.optional(),
})

const getTasksQuerySchema = z.object({
  status: taskStatusEnum.optional(),
  clientId: z.coerce.number().int().positive().optional(),
})

// Cria uma nova tarefa associada a um cliente específico.
// Valida se o cliente pertence ao usuário autenticado.
export async function createTask(req: Request, res: Response) {
  const parsed = createTaskSchema.safeParse(req.body)
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.issues[0].message })
  }

  const { title, description, clientId } = parsed.data

  try {
    const client = await prisma.client.findUnique({ where: { id: clientId } })

    if (!client) return res.status(404).json({ error: 'Cliente não encontrado' })
    if (client.userId !== req.userId) return res.status(403).json({ error: 'Acesso negado' })

    const task = await prisma.task.create({
      data: { title, description, clientId }
    })
    return res.status(201).json(task)
  } catch (err) {
    logger.error(err, 'Erro ao criar tarefa')
    return res.status(500).json({ error: 'Erro interno do servidor' })
  }
}

// Lista tarefas do usuário autenticado com filtros opcionais por status e/ou clientId.
// Cada tarefa retornada inclui os dados do cliente relacionado.
export async function getTasks(req: Request, res: Response) {
  const parsed = getTasksQuerySchema.safeParse(req.query)
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.issues[0].message })
  }

  const { status, clientId } = parsed.data

  try {
    const tasks = await prisma.task.findMany({
      where: {
        client: { userId: req.userId },
        ...(status && { status }),
        ...(clientId && { clientId }),
      },
      include: { client: true }
    })
    return res.json(tasks)
  } catch (err) {
    logger.error(err, 'Erro ao buscar tarefas')
    return res.status(500).json({ error: 'Erro interno do servidor' })
  }
}

// Atualiza título, descrição e/ou status de uma tarefa pelo seu id.
// Valida se a tarefa pertence ao usuário autenticado.
export async function updateTask(req: Request, res: Response) {
  const { id } = req.params

  const parsed = updateTaskSchema.safeParse(req.body)
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.issues[0].message })
  }

  try {
    const task = await prisma.task.findUnique({
      where: { id: Number(id) },
      include: { client: true }
    })

    if (!task) return res.status(404).json({ error: 'Tarefa não encontrada' })
    if (task.client.userId !== req.userId) return res.status(403).json({ error: 'Acesso negado' })

    const updated = await prisma.task.update({
      where: { id: Number(id) },
      data: parsed.data
    })
    return res.json(updated)
  } catch (err) {
    logger.error(err, 'Erro ao atualizar tarefa')
    return res.status(500).json({ error: 'Erro interno do servidor' })
  }
}

// Remove uma tarefa pelo id. Responde com 204 (sem corpo) em caso de sucesso.
// Valida se a tarefa pertence ao usuário autenticado.
export async function deleteTask(req: Request, res: Response) {
  const { id } = req.params

  try {
    const task = await prisma.task.findUnique({
      where: { id: Number(id) },
      include: { client: true }
    })

    if (!task) return res.status(404).json({ error: 'Tarefa não encontrada' })
    if (task.client.userId !== req.userId) return res.status(403).json({ error: 'Acesso negado' })

    await prisma.task.delete({ where: { id: Number(id) } })
    return res.status(204).send()
  } catch (err) {
    logger.error(err, 'Erro ao deletar tarefa')
    return res.status(500).json({ error: 'Erro interno do servidor' })
  }
}
