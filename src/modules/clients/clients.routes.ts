import { Router } from 'express'
import { createClient, getClients, updateClient, deleteClient } from './clients.controller'
import { authMiddleware } from '../../middlewares/auth.middleware'

const router = Router()

router.use(authMiddleware)

router.post('/', createClient)
router.get('/', getClients)
router.put('/:id', updateClient)
router.delete('/:id', deleteClient)

export default router