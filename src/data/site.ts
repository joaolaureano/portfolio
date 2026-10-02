export const site = {
  name: 'João Pedro Laureano',
  role: 'Backend Engineer',
  location: 'Porto Alegre, Brazil',
  description:
    'Backend engineer at Mercado Livre. Go services, distributed systems and the tools to measure them.',
  avatar: 'https://github.com/joaolaureano.png?size=520',
  email: 'laureano.pedrojoao@gmail.com',
  links: {
    github: 'https://github.com/joaolaureano',
    linkedin: 'https://www.linkedin.com/in/joao-pedro-laureano',
  },
  // GoatCounter site code (the "xyz" in xyz.goatcounter.com). Empty disables analytics.
  goatcounter: '',
};

export type Role = {
  title: string;
  period: string;
  bullets: string[];
};

export type Job = {
  company: string;
  url: string;
  location: string;
  period: string;
  blurb: string;
  roles: Role[];
};

export const experience: Job[] = [
  {
    company: 'Mercado Livre',
    url: 'https://www.mercadolivre.com.br',
    location: 'Florianópolis, Brazil',
    period: '2022 – now',
    blurb: 'Largest e-commerce and logistics company in Latin America.',
    roles: [
      {
        title: 'Backend Developer',
        period: 'Sep 2022 – now',
        bullets: [
          'Played an active part in the sharding initiative that decoupled the totem services in production: environment setup, a reverse proxy written in Go, ETL scripts for the data load, and a migration monitored on Datadog with stable response times throughout.',
          'Designed socket-based communication with PLC and PTL devices on the distribution-center floor: a protocol plugin architecture, checksum validation, heartbeats, ACK/NACK handling, goroutine-based multi-module support and configuration changed at runtime.',
          'Build Go services and REST APIs that support millions of daily package deliveries across Brazil, integrating several APIs concurrently, observed with OpenTelemetry, Datadog and New Relic.',
          'Tuned SQL through index management, query rewrites and denormalization; review code and keep automated test coverage at 80–100%.',
        ],
      },
    ],
  },
  {
    company: 'Dell Technologies',
    url: 'https://www.dell.com',
    location: 'Porto Alegre, Brazil',
    period: '2019 – 2022',
    blurb: 'Enterprise infrastructure and global support services.',
    roles: [
      {
        title: 'Software Engineer',
        period: 'Jul 2019 – Sep 2022',
        bullets: [
          'Designed, built and documented 10+ automations that close incidents and alerts across Dell’s global support infrastructure.',
          'Cut manual effort by up to 70% with preventive automations: server cleanup, credential resets and workflow stabilization in production.',
          'Sole developer on an incident-focused team, working with the Product Owner and presenting to international stakeholders in English.',
          'Mentored colleagues, including international teammates, into automation developers through training, code review, coding dojos, pair programming and Scrum.',
        ],
      },
    ],
  },
];

export const education = [
  {
    school: 'Faculdade Brasília',
    degree: 'Postgraduate, Full Cycle Architecture',
    period: '2023 – 2024',
  },
  {
    school: 'PUCRS',
    degree: 'B.Sc. Software Engineering',
    period: '2018 – 2023',
  },
];

export const skills: { group: string; items: string[] }[] = [
  { group: 'Languages', items: ['Go', 'Java', 'TypeScript', 'SQL'] },
  { group: 'Systems', items: ['Microservices', 'Kafka', 'Flink', 'REST', 'Sockets', 'Sharding'] },
  { group: 'Data', items: ['PostgreSQL', 'SQLite', 'DuckDB', 'KVS / NoSQL'] },
  { group: 'Cloud & ops', items: ['AWS', 'Terraform / OpenTofu', 'Docker', 'Datadog', 'OpenTelemetry'] },
];
