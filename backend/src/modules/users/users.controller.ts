import { Request, Response } from 'express'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { z } from 'zod'
import prisma from '../../prisma'
import logger from '../../logger'

const registerSchema = z.object({
  email: z.string().email({ message: 'E-mail inválido' }),
  password: z.string().min(6, { message: 'A senha deve ter no mínimo 6 caracteres' }),
})

const loginSchema = z.object({
  email: z.string().email({ message: 'E-mail inválido' }),
  password: z.string().min(1, { message: 'Senha obrigatória' }),
})

// Cadastra um novo usuário. Verifica se o e-mail já existe, faz o hash da senha
// e salva no banco. Retorna o id e e-mail do usuário criado.
export async function register(req: Request, res: Response) {
  const parsed = registerSchema.safeParse(req.body)
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.issues[0].message })
  }

  const { email, password } = parsed.data

  try {
    const existingUser = await prisma.user.findUnique({ where: { email } })
    if (existingUser) {
      return res.status(400).json({ error: 'Email já cadastrado' })
    }

    const hashedPassword = await bcrypt.hash(password, 10)

    const user = await prisma.user.create({
      data: { email, password: hashedPassword }
    })

    return res.status(201).json({ id: user.id, email: user.email })
  } catch (err) {
    logger.error(err, 'Erro ao registrar usuário')
    return res.status(500).json({ error: 'Erro interno do servidor' })
  }
}

// Autentica um usuário. Confere se o e-mail existe e se a senha bate com o hash
// armazenado. Em caso de sucesso, devolve um JWT válido por 1 dia.
export async function login(req: Request, res: Response) {
  const parsed = loginSchema.safeParse(req.body)
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.issues[0].message })
  }

  const { email, password } = parsed.data

  try {
    const user = await prisma.user.findUnique({ where: { email } })
    if (!user) {
      return res.status(401).json({ error: 'Credenciais inválidas' })
    }

    const passwordMatch = await bcrypt.compare(password, user.password)
    if (!passwordMatch) {
      return res.status(401).json({ error: 'Credenciais inválidas' })
    }

    const token = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET as string,
      { expiresIn: '1d' }
    )

    return res.json({ token })
  } catch (err) {
    logger.error(err, 'Erro ao autenticar usuário')
    return res.status(500).json({ error: 'Erro interno do servidor' })
  }
}
