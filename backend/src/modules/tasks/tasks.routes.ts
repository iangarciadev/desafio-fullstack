import { Router } from 'express'
import { createTask, getTasks, updateTask, deleteTask } from './tasks.controller'
import { authMiddleware } from '../../middlewares/auth.middleware'

const router = Router()
router.use(authMiddleware)

/**
 * @openapi
 * tags:
 *   name: Tasks
 *   description: Gerenciamento de tarefas (requer autenticação)
 */

/**
 * @openapi
 * /tasks:
 *   post:
 *     tags: [Tasks]
 *     summary: Criar nova tarefa
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, clientId]
 *             properties:
 *               title:
 *                 type: string
 *                 example: Entrar em contato
 *               description:
 *                 type: string
 *                 example: Ligar para o cliente às 14h
 *               clientId:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       201:
 *         description: Tarefa criada com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Task'
 *       401:
 *         description: Não autorizado
 *       403:
 *         description: Cliente não pertence ao usuário
 *       404:
 *         description: Cliente não encontrado
 */
router.post('/', createTask)

/**
 * @openapi
 * /tasks:
 *   get:
 *     tags: [Tasks]
 *     summary: Listar tarefas do usuário autenticado
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [PENDING, IN_PROGRESS, DONE]
 *         description: Filtrar por status
 *       - in: query
 *         name: clientId
 *         schema:
 *           type: integer
 *         description: Filtrar por ID do cliente
 *     responses:
 *       200:
 *         description: Lista de tarefas com dados do cliente
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 allOf:
 *                   - $ref: '#/components/schemas/Task'
 *                   - type: object
 *                     properties:
 *                       client:
 *                         $ref: '#/components/schemas/Client'
 *       401:
 *         description: Não autorizado
 */
router.get('/', getTasks)

/**
 * @openapi
 * /tasks/{id}:
 *   put:
 *     tags: [Tasks]
 *     summary: Atualizar tarefa
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID da tarefa
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               status:
 *                 type: string
 *                 enum: [PENDING, IN_PROGRESS, DONE]
 *     responses:
 *       200:
 *         description: Tarefa atualizada com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Task'
 *       401:
 *         description: Não autorizado
 *       403:
 *         description: Acesso negado
 *       404:
 *         description: Tarefa não encontrada
 */
router.put('/:id', updateTask)

/**
 * @openapi
 * /tasks/{id}:
 *   delete:
 *     tags: [Tasks]
 *     summary: Remover tarefa
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID da tarefa
 *     responses:
 *       204:
 *         description: Tarefa removida com sucesso
 *       401:
 *         description: Não autorizado
 *       403:
 *         description: Acesso negado
 *       404:
 *         description: Tarefa não encontrada
 */
router.delete('/:id', deleteTask)

export default router
