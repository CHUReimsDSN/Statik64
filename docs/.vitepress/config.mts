import { defineConfig } from 'vitepress'
import { sidebar } from './generated/sidebar'
import { version } from './generated/version'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Statik64 - Rails",
  description: "Statik64 for Rails",
  base: '/Statik64-Rails/',
  themeConfig: {
    nav: [
      { text: 'Documentation', link: '/documentation/000_index' },
      { text: version, link: 'changelog' },
    ],

    sidebar,
    outlineTitle: 'Sur cette page',
    socialLinks: [
      { icon: 'github', link: 'https://github.com/CHUReimsDSN/Statik64-Rails' }
    ],
    docFooter: {
      prev: false,
      next: false
    },
    search: {
      provider: 'local',
      options: {
        translations: {
          button: {
            buttonText: 'Recherche'
          },
          modal: {
            footer: {
              navigateText: 'Naviguer',
              selectText: 'Sélectionner',
              closeText: 'Fermer',
            },
            noResultsText: 'Aucun résultat pour '
          },
          
        }
      }
    }
  },
})
