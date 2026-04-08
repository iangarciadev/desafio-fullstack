import { Router } from 'express'
import { createClient, getClients, updateClient, deleteClient } from './clients.controller'
import { authMiddleware } from '../../middlewares/auth.middleware'

const router = Router()
router.use(authMiddleware)

/**
 * @openapi
 * tags:
 *   name: Clients
 *   description: Gerenciamento de clientes (requer autenticação)
 */

/**
 * @openapi
 * /clients:
 *   post:
 *     tags: [Clients]
 *     summary: Criar novo cliente
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, email]
 *             properties:
 *               name:
 *                 type: string
 *                 example: João Silva
 *               email:
 *                 type: string
 *                 example: joao@email.com
 *               cep:
 *                 type: string
 *                 example: 01310-100
 *               logradouro:
 *                 type: string
 *                 example: Av. Paulista
 *               numero:
 *                 type: string
 *                 example: "1000"
 *               complemento:
 *                 type: string
 *                 example: Apto 42
 *               bairro:
 *                 type: string
 *                 example: Bela Vista
 *               cidade:
 *                 type: string
 *                 example: São Paulo
 *               estado:
 *                 type: string
 *                 example: SP
 *     responses:
 *       201:
 *         description: Cliente criado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Client'
 *       401:
 *         description: Não autorizado
 */
router.post('/', createClient)

/**
 * @openapi
 * /clients:
 *   get:
 *     tags: [Clients]
 *     summary: Listar todos os clientes do usuário autenticado
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de clientes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Client'
 *       401:
 *         description: Não autorizado
 */
router.get('/', getClients)

/**
 * @openapi
 * /clients/{id}:
 *   put:
 *     tags: [Clients]
 *     summary: Atualizar cliente
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID do cliente
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               cep:
 *                 type: string
 *               logradouro:
 *                 type: string
 *               numero:
 *                 type: string
 *               complemento:
 *                 type: string
 *               bairro:
 *                 type: string
 *               cidade:
 *                 type: string
 *               estado:
 *                 type: string
 *     responses:
 *       200:
 *         description: Cliente atualizado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Client'
 *       401:
 *         description: Não autorizado
 *       403:
 *         description: Acesso negado
 *       404:
 *         description: Cliente não encontrado
 */
router.put('/:id', updateClient)

/**
 * @openapi
 * /clients/{id}:
 *   delete:
 *     tags: [Clients]
 *     summary: Remover cliente
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID do cliente
 *     responses:
 *       204:
 *         description: Cliente removido com sucesso
 *       401:
 *         description: Não autorizado
 *       403:
 *         description: Acesso negado
 *       404:
 *         description: Cliente não encontrado
 */
router.delete('/:id', deleteClient)

export default router
