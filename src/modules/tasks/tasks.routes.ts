import { Router } from 'express'
import { createTask, getTasks, updateTask, deleteTask } from './tasks.controller'
import { authMiddleware } from '../../middlewares/auth.middleware'

const router = Router()

router.use(authMiddleware)

router.post('/', createTask)
router.get('/', getTasks)
router.put('/:id', updateTask)
router.delete('/:id', deleteTask)

export default router