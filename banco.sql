-- ============================================================
-- BANCO DE DADOS DO PAINEL DA ISABELA MAIO
-- ============================================================
-- Como usar este arquivo:
-- 1. Entre no seu projeto em supabase.com
-- 2. No menu da esquerda, clique em "SQL Editor"
-- 3. Clique em "New query"
-- 4. Cole TODO o conteúdo deste arquivo
-- 5. Clique em "Run" (ou aperte Cmd+Enter)
-- Isso cria as 6 tabelas, as travas de segurança e uma linha de
-- exemplo em cada lista. Só precisa rodar isso UMA vez.
-- ============================================================


-- ------------------------------------------------------------
-- BLOCO 0: ligar a função que gera códigos únicos (gen_random_uuid)
-- Sem isso, o banco não consegue criar um "id" sozinho pra cada linha.
-- ------------------------------------------------------------
create extension if not exists pgcrypto;


-- ------------------------------------------------------------
-- BLOCO 1: tabela VIDEOS
-- Cada linha é um vídeo do seu portfólio.
-- "destaque" só se preenche quando o vídeo deve aparecer na seção
-- "Conteúdos de destaque" da capa do site (ex: "2,4M views no reels").
-- Se "destaque" ficar em branco, o vídeo aparece só na galeria por nicho.
-- "ordem" decide a posição (menor número aparece primeiro).
-- "visivel" decide se o vídeo aparece no site público ou fica escondido.
-- ------------------------------------------------------------
create table videos (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  link text,
  nicho text,
  formato text,
  marca text,
  destaque text,
  ordem integer not null default 0,
  visivel boolean not null default true,
  criado_em timestamptz not null default now()
);

-- Liga a trava de segurança nesta tabela
alter table videos enable row level security;

-- Só quem está logada (você) pode ler, criar, editar e apagar vídeos
create policy "videos_logada_tudo" on videos
  for all
  to authenticated
  using (true)
  with check (true);

-- Exceção 1: qualquer pessoa (sem login) pode LER os vídeos marcados
-- como visíveis. É isso que faz o site público mostrar os vídeos.
-- Vídeos escondidos (visivel = false) continuam invisíveis pra quem
-- não está logado.
create policy "videos_publico_le_visiveis" on videos
  for select
  to anon
  using (visivel = true);

-- Uma linha de exemplo, só pra você ver o formato. Pode apagar no admin.
insert into videos (titulo, link, nicho, formato, marca, destaque, ordem, visivel)
values ('Vídeo de exemplo (apague depois)', '', 'beleza', 'Reels', 'Marca de exemplo', '', 1, true);


-- ------------------------------------------------------------
-- BLOCO 2: tabela MARCAS
-- A sua base de contatos de empresas.
-- "situacao" só pode ser um destes 4 valores: Lead, Conversando,
-- Cliente ou Parada.
-- ------------------------------------------------------------
create table marcas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  instagram text,
  email text,
  telefone text,
  situacao text not null default 'Lead' check (situacao in ('Lead', 'Conversando', 'Cliente', 'Parada')),
  obs text,
  ultimo_contato date,
  criado_em timestamptz not null default now()
);

alter table marcas enable row level security;

-- Só quem está logada (você) pode ler, editar e apagar marcas
create policy "marcas_logada_tudo" on marcas
  for all
  to authenticated
  using (true)
  with check (true);

-- Exceção 2: qualquer pessoa pode CADASTRAR uma marca nova (isso é o
-- formulário de contato do seu site enviando um lead), mas só como
-- situação "Lead". Ninguém de fora consegue ler a lista nem mudar
-- marcas que já existem.
create policy "marcas_publico_insere_lead" on marcas
  for insert
  to anon
  with check (situacao = 'Lead');

insert into marcas (nome, instagram, email, telefone, situacao, obs, ultimo_contato)
values ('Marca de exemplo (apague depois)', '@exemplo', 'exemplo@email.com', '', 'Lead', 'Isso é só um exemplo do formato. Pode apagar.', current_date);


-- ------------------------------------------------------------
-- BLOCO 3: tabela CALENDARIO
-- Os itens da sua agenda (gravar, editar, postar).
-- ------------------------------------------------------------
create table calendario (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  marca text,
  tipo text not null default 'gravar' check (tipo in ('gravar', 'editar', 'postar')),
  data date not null,
  status text not null default 'a fazer' check (status in ('a fazer', 'feito')),
  criado_em timestamptz not null default now()
);

alter table calendario enable row level security;

-- Só quem está logada (você) pode ler, criar, editar e apagar
create policy "calendario_logada_tudo" on calendario
  for all
  to authenticated
  using (true)
  with check (true);

insert into calendario (titulo, marca, tipo, data, status)
values ('Tarefa de exemplo (apague depois)', '', 'gravar', current_date, 'a fazer');


-- ------------------------------------------------------------
-- BLOCO 4: tabela CAMPANHAS
-- O controle de propostas e pagamentos com as marcas.
-- "status" segue sempre esta ordem (funil): Briefing, Roteiro,
-- Aprovação Roteiro, Gravação, Edição, Aprovado, Entregue.
-- ------------------------------------------------------------
create table campanhas (
  id uuid primary key default gen_random_uuid(),
  campanha text not null,
  cliente text,
  tipo text not null default 'Conteúdo' check (tipo in ('Conteúdo', 'Publicidade')),
  status text not null default 'Briefing' check (status in ('Briefing', 'Roteiro', 'Aprovação Roteiro', 'Gravação', 'Edição', 'Aprovado', 'Entregue')),
  qtd integer not null default 1,
  valor numeric(12,2) not null default 0,
  prazo date,
  pagamento text not null default 'pendente' check (pagamento in ('pendente', 'pago')),
  ativa boolean not null default true,
  favorita boolean not null default false,
  criado_em timestamptz not null default now()
);

alter table campanhas enable row level security;

-- Só quem está logada (você) pode ler, criar, editar e apagar
create policy "campanhas_logada_tudo" on campanhas
  for all
  to authenticated
  using (true)
  with check (true);

insert into campanhas (campanha, cliente, tipo, status, qtd, valor, prazo, pagamento, ativa, favorita)
values ('Campanha de exemplo (apague depois)', 'Cliente de exemplo', 'Conteúdo', 'Briefing', 1, 0, current_date + interval '7 days', 'pendente', true, false);


-- ------------------------------------------------------------
-- BLOCO 5: tabela MARCADOS
-- Guarda quais itens do checklist do portfólio você já marcou.
-- Cada item tem uma "chave" de texto única (ex: "capa-0").
-- Não tem linha de exemplo aqui: começa realmente vazia.
-- ------------------------------------------------------------
create table marcados (
  chave text primary key,
  marcado boolean not null default true,
  atualizado_em timestamptz not null default now()
);

alter table marcados enable row level security;

-- Só quem está logada (você) pode ler, criar, editar e apagar
create policy "marcados_logada_tudo" on marcados
  for all
  to authenticated
  using (true)
  with check (true);


-- ------------------------------------------------------------
-- BLOCO 6: tabela VISITAS
-- Um registro simples de visita ao portfólio, pras métricas.
-- Não tem linha de exemplo aqui: começa realmente em zero, como você pediu.
-- ------------------------------------------------------------
create table visitas (
  id uuid primary key default gen_random_uuid(),
  data timestamptz not null default now(),
  pagina text,
  origem text
);

alter table visitas enable row level security;

-- Só quem está logada (você) pode ler e apagar visitas
create policy "visitas_logada_tudo" on visitas
  for all
  to authenticated
  using (true)
  with check (true);

-- Exceção 3: qualquer pessoa (sem login) pode REGISTRAR uma visita.
-- Isso é o próprio site público anotando "alguém entrou aqui".
-- Ninguém de fora consegue ler a lista de visitas.
create policy "visitas_publico_insere" on visitas
  for insert
  to anon
  with check (true);


-- ============================================================
-- FIM. Depois de rodar, veja no arquivo abaixo (ou na mensagem
-- que a Claude te mandou) como conferir se a trava funcionou.
-- ============================================================
