-- AlterTable companies: add config column
ALTER TABLE "companies" ADD COLUMN IF NOT EXISTS "config" JSONB;

-- AlterTable whatsapp_sessions: add ai_enabled

ALTER TABLE "whatsapp_sessions" ADD COLUMN IF NOT EXISTS "ai_enabled" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable users: add ai_instruction
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "ai_instruction" TEXT;

-- AlterTable contacts: add missing columns
ALTER TABLE "contacts" ADD COLUMN IF NOT EXISTS "tags" TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE "contacts" ADD COLUMN IF NOT EXISTS "notes" TEXT;
ALTER TABLE "contacts" ADD COLUMN IF NOT EXISTS "kanban_status" TEXT NOT NULL DEFAULT 'lead';

-- CreateTable contact_activities (if not exists)
CREATE TABLE IF NOT EXISTS "contact_activities" (
    "id" TEXT NOT NULL,
    "contact_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "duration" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "contact_activities_pkey" PRIMARY KEY ("id")
);

-- CreateTable quick_replies (if not exists)
CREATE TABLE IF NOT EXISTS "quick_replies" (
    "id" TEXT NOT NULL,
    "company_id" TEXT NOT NULL,
    "shortcut" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "quick_replies_pkey" PRIMARY KEY ("id")
);

-- CreateIndex (if not exists)
CREATE UNIQUE INDEX IF NOT EXISTS "quick_replies_company_id_shortcut_key" ON "quick_replies"("company_id", "shortcut");

-- AddForeignKey contact_activities -> contacts
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'contact_activities_contact_id_fkey'
  ) THEN
    ALTER TABLE "contact_activities" ADD CONSTRAINT "contact_activities_contact_id_fkey"
      FOREIGN KEY ("contact_id") REFERENCES "contacts"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

-- AddForeignKey contact_activities -> users
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'contact_activities_user_id_fkey'
  ) THEN
    ALTER TABLE "contact_activities" ADD CONSTRAINT "contact_activities_user_id_fkey"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

-- AddForeignKey quick_replies -> companies
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'quick_replies_company_id_fkey'
  ) THEN
    ALTER TABLE "quick_replies" ADD CONSTRAINT "quick_replies_company_id_fkey"
      FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;
