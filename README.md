# LunarEmailServer

Stack Docker/Portainer para hospedar um servidor de e-mail self-hosted com Poste.io FREE.

## Arquitetura

O Poste.io roda com `network_mode: host`, preservando o IP real das conexoes SMTP/IMAP.

Interface web:

- HTTP interno: `3230`
- HTTPS interno: `3231`
- Recomendado: publicar `mail.seudominio.com.br` por Nginx/Nginx Proxy Manager/Traefik apontando para `http://IP_DA_VPS:3230`

As portas de e-mail continuam diretamente na VPS:

- `25/tcp` SMTP entre servidores
- `465/tcp` SMTPS
- `587/tcp` Submission / STARTTLS
- `993/tcp` IMAPS
- `995/tcp` POP3S (opcional)
- `110/tcp` POP3 (opcional)
- `143/tcp` IMAP + STARTTLS (opcional)
- `4190/tcp` Sieve (opcional)

## Deploy pelo Portainer

1. Abra `Stacks` > `Add stack`.
2. Selecione `Repository`.
3. Repository URL:

   `https://github.com/RafaelRodriguesDev/LunarEmailServer.git`

4. Compose path:

   `docker-compose.yml`

5. Em `Environment variables`, cadastre:

   - `POSTE_HOSTNAME=mail.seudominio.com.br`
   - `POSTE_HTTP_PORT=3230`
   - `POSTE_HTTPS_PORT=3231`
   - `POSTE_DATA_PATH=/opt/poste/data`
   - `TZ=America/Sao_Paulo`

6. Clique em `Deploy the stack`.

## Configuracao via Docker Compose

```bash
cp .env.example .env
nano .env
docker compose up -d
```

## Reverse proxy

Exemplo:

```text
mail.seudominio.com.br -> http://IP_DA_VPS:3230
```

O Compose usa `HTTPS=OFF` para desativar o redirecionamento forcado do HTTP para o HTTPS interno. A porta HTTPS interna fica em `3231`, evitando disputa pela `443` do host.

Se voce usa Let's Encrypt dentro do proprio Poste.io, sera necessario encaminhar corretamente `/.well-known/`. Se o certificado for gerenciado pelo seu reverse proxy, normalmente deixe o proxy cuidar do HTTPS da interface web.

## DNS minimo

Hostname do servidor:

```text
mail.seudominio.com.br  A      IP_DA_VPS
PTR do IP               ->     mail.seudominio.com.br
```

Para cada dominio hospedado:

```text
seudominio.com.br       MX 10  mail.seudominio.com.br
```

Depois configure SPF, DKIM e DMARC conforme o diagnostico do Poste.io.

## Firewall minimo

```bash
sudo ufw allow 25/tcp
sudo ufw allow 465/tcp
sudo ufw allow 587/tcp
sudo ufw allow 993/tcp
```

Se usar POP3/Sieve, abra tambem as portas correspondentes.

## Persistencia

Todos os dados ficam, por padrao, em:

```text
/opt/poste/data
```

Esse diretorio contem configuracoes, usuarios, mensagens, banco e logs. Nunca apague esse volume ao atualizar o container.

## Backup

```bash
sudo POSTE_DATA_PATH=/opt/poste/data ./scripts/backup.sh
```

Por padrao os backups sao gravados em:

```text
/opt/poste/backups
```

## Atualizacao

Faca backup antes de atualizar:

```bash
docker compose pull
docker compose up -d
```

## Seguranca

- Nao armazene senhas ou tokens reais neste repositorio.
- Use variaveis do Portainer ou um arquivo `.env` local ignorado pelo Git.
- Garanta PTR/rDNS, MX, SPF, DKIM e DMARC corretos antes de colocar o servidor em producao.
- A porta 25 precisa estar liberada pelo provedor da VPS para receber e enviar e-mail entre servidores.
