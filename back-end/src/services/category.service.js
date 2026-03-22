import pool from '../config/database.js';

export async function listCategories(query = {}) {
  const topLevelOnly =
    query.top_level === 'true' ||
    query.top_level === '1' ||
    query.top_level === true;

  const filters = ['c.is_active = TRUE'];
  const params = [];

  if (topLevelOnly) {
    filters.push('c.parent_id IS NULL');
  }

  const [rows] = await pool.query(
    `SELECT
        c.id,
        c.name,
        c.name_ar,
        c.description,
        c.icon,
        c.color,
        c.parent_id,
        c.display_order,
        COUNT(ts.id) AS active_sites_count
     FROM categories c
     LEFT JOIN tourist_sites ts
       ON ts.category_id = c.id
      AND ts.deleted_at IS NULL
      AND ts.is_active = TRUE
     WHERE ${filters.join(' AND ')}
     GROUP BY
       c.id,
       c.name,
       c.name_ar,
       c.description,
       c.icon,
       c.color,
       c.parent_id,
       c.display_order
     ORDER BY
       CASE WHEN c.parent_id IS NULL THEN 0 ELSE 1 END,
       c.display_order ASC,
       c.name ASC`,
    params
  );

  const categories = rows.map((row) => ({
    ...row,
    active_sites_count: Number(row.active_sites_count || 0),
    children: []
  }));

  const byId = new Map(categories.map((category) => [category.id, category]));
  const roots = [];

  for (const category of categories) {
    if (category.parent_id == null) {
      roots.push(category);
      continue;
    }

    const parent = byId.get(category.parent_id);
    if (parent) {
      parent.children.push(category);
    }
  }

  if (topLevelOnly) {
    return roots;
  }

  return categories;
}
