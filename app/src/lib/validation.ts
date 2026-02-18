import { z } from "zod";

const chefPersonalitySchema = z.enum([
  "professional",
  "friendly",
  "motherly",
  "coach",
  "scientific",
  "custom",
]);

const speakingStyleSchema = z.object({
  formality: z.enum(["formal", "casual"]),
  emojiUsage: z.enum(["high", "medium", "low", "none"]),
  technicality: z.enum(["expert", "general", "beginner"]),
});

export const aiChefConfigSchema = z.object({
  name: z.string().min(1),
  personality: chefPersonalitySchema,
  customPersonality: z.string().optional(),
  expertise: z.array(z.string()).min(1),
  cookingPhilosophy: z.string().optional(),
  speakingStyle: speakingStyleSchema,
});

export const chatRequestSchema = z.object({
  message: z.string().min(1),
  chefConfig: aiChefConfigSchema,
  context: z
    .object({
      ingredients: z.array(z.string()).optional(),
      tools: z.array(z.string()).optional(),
    })
    .optional(),
});

export const recipeRequestSchema = z.object({
  ingredients: z.array(z.string()).min(1),
  tools: z.array(z.string()).default([]),
  preferences: z
    .object({
      cuisine: z.string().optional(),
      difficulty: z.enum(["easy", "medium", "hard"]).optional(),
      cookingTime: z.number().optional(),
      servings: z.number().optional(),
    })
    .default({}),
  chefConfig: aiChefConfigSchema,
});

export type ChatRequest = z.infer<typeof chatRequestSchema>;
export type RecipeRequest = z.infer<typeof recipeRequestSchema>;
