# Field Service App

Aplicativo desenvolvido em Flutter como desafio técnico para simular o fluxo de trabalho de técnicos em campo.

A proposta do projeto é permitir que ordens de serviço sejam consultadas, preenchidas e registradas mesmo em situações sem conexão com a internet, mantendo os dados armazenados localmente até que seja possível sincronizá-los com a API.

## Sobre o projeto

O aplicativo foi pensado para um cenário de atendimento em campo, onde o técnico precisa:

- realizar login;
- visualizar ordens de serviço;
- abrir os detalhes de uma ordem;
- preencher uma inspeção;
- adicionar uma foto;
- capturar localização por GPS;
- salvar a inspeção como rascunho;
- concluir uma inspeção mesmo sem internet;
- consultar o histórico local;
- sincronizar os dados posteriormente com a API.

O principal foco do desenvolvimento foi o comportamento offline e o processo de sincronização.

## Tecnologias utilizadas

- Flutter
- Dart
- Provider
- HTTP
- SQLite com `sqflite`
- `flutter_secure_storage`
- `image_picker`
- `geolocator`
- `path_provider`
- `connectivity_plus`
- UUID
- Git

## Arquitetura

O projeto foi organizado separando responsabilidades entre telas, providers, models e services.

Estrutura principal:

```text
lib/
├── core/
├── models/
├── providers/
├── screens/
│   ├── home/
│   ├── inspection/
│   ├── login/
│   ├── splash/
│   └── work_order/
├── services/
├── utils/
└── widgets/
```

## Fluxo offline

O aplicativo foi projetado para não depender de uma conexão contínua. Quando uma inspeção é criada ou alterada, seus dados são registrados primeiro no banco local. A partir daí, a aplicação decide se deve apenas manter o registro no dispositivo ou tentar enviá-lo para o servidor.  
Sem conexão, a inspeção continua disponível localmente e pode ser consultada ou editada. Quando a internet retorna, o monitor de conectividade inicia uma nova tentativa de sincronização dos registros pendentes. O usuário também pode acionar a sincronização manualmente.

O fluxo evita que uma falha temporária de rede interrompa o trabalho ou provoque a perda do formulário preenchido.

## Rascunhos

Uma inspeção pode ser salva como rascunho antes de estar pronta para envio. O status `draft` indica que o preenchimento ainda não foi concluído ou que o usuário decidiu continuar mais tarde.

Ao abrir novamente a mesma ordem de serviço, o aplicativo recupera as informações salvas no SQLite, permitindo continuar o preenchimento do ponto em que ele foi interrompido. Rascunhos não são enviados automaticamente ao servidor até que a inspeção seja finalizada.

## Persistência de imagens

As imagens não dependem apenas do caminho temporário retornado pela câmera. Após a captura, o arquivo é copiado para um diretório persistente da aplicação, obtido com `path_provider`.

O banco local armazena a referência para esse arquivo. Assim, a foto continua disponível depois que o aplicativo é fechado ou reiniciado e pode ser recuperada durante a edição do rascunho ou em uma tentativa posterior de sincronização.

Quando uma inspeção é enviada, a imagem persistida é associada aos demais dados conforme o contrato definido pela API.

## Identificação com `clientId` e `serverId`

Cada inspeção recebe um `clientId` gerado localmente com UUID. Esse identificador existe desde a criação do registro, inclusive quando o dispositivo está offline, e permite reconhecer a mesma inspeção em todas as tentativas de envio.

Após a criação do registro na API, o identificador retornado pelo backend é armazenado como `serverId`.

- `clientId`: criado no dispositivo e disponível imediatamente;
- `serverId`: criado ou confirmado pelo servidor após a sincronização.

A separação ajuda a evitar duplicidades, mantém a rastreabilidade entre o banco local e o remoto e permite atualizar corretamente uma inspeção já enviada.

## Status das inspeções

| Status    | Significado                                                          |
| --------- | -------------------------------------------------------------------- |
| `draft`   | Inspeção salva como rascunho e ainda não finalizada.                 |
| `pending` | Inspeção finalizada localmente e aguardando envio ou nova tentativa. |
| `synced`  | Dados enviados e confirmados pelo servidor.                          |
| `failed`  | A última tentativa de sincronização falhou e pode ser repetida.      |

## Autor

Desenvolvido por **João Victor Ferreira da Silva**.
