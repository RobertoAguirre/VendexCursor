require('dotenv').config();
const { Pool } = require('pg');

console.log('🔍 Probando conexión a Supabase...');
console.log('URL:', process.env.DATABASE_URL ? process.env.DATABASE_URL.substring(0, 50) + '...' : 'No encontrada');

const pool = new Pool({ 
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Error:', err.message);
    console.error('Código:', err.code);
    process.exit(1);
  } else {
    console.log('✅ Conexión exitosa!');
    console.log('Fecha del servidor:', res.rows[0].now);
    process.exit(0);
  }
});
