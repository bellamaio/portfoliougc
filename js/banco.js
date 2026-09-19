// ============================================================
// Conexão com o banco de dados (Supabase)
// Usado pelo site, pela tela de login e pelo painel admin.
//
// As duas informações abaixo NÃO são segredo: a URL do projeto e a
// chave pública (anon) são feitas pra ficar visíveis no navegador.
// Quem protege os dados de verdade são as regras de segurança (RLS)
// que estão no arquivo banco.sql.
//
// NUNCA coloque aqui a "service role key" (a chave secreta). Essa
// chave dá acesso total ao banco, sem nenhuma trava.
// ============================================================

const SUPABASE_URL = "https://ffrvcrqzymvrexrbxfve.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_hPxWzJQekl5VjSqmMDzamA_DMf3SQJj";

window.supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
