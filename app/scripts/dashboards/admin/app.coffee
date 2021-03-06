'use strict'

panels = [
  {
    name: 'System'
    slug: 'system'
    panels: ['overview', 'info']
  },
  {
    name: 'Instance'
    slug: 'instance'
    panels: ['instance', 'flavor']
  }
]

dashboard =
  slug: 'admin'
  permissions: 'role.admin'

$cross.registerDashboard(dashboard, panels)
