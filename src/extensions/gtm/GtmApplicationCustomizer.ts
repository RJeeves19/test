import { BaseApplicationCustomizer } from '@microsoft/sp-application-base';
import { Log } from '@microsoft/sp-core-library';

const LOG_SOURCE: string = 'GtmApplicationCustomizer';

// Define the dataLayer type
declare global {
  interface Window {
    dataLayer: any[];
  }
}

export interface IGtmApplicationCustomizerProperties {
  gtmContainerId: string;
}

export default class GtmApplicationCustomizer
  extends BaseApplicationCustomizer<IGtmApplicationCustomizerProperties> {

  protected onInit(): Promise<void> {
    Log.info(LOG_SOURCE, 'Initialized GtmApplicationCustomizer');

    // Initialize dataLayer
    window.dataLayer = window.dataLayer || [];

    // Get the GTM container ID from properties
    const gtmContainerId = this.properties.gtmContainerId;
    if (!gtmContainerId) {
      Log.warn(LOG_SOURCE, 'GTM Container ID is not configured');
      return Promise.resolve();
    }

    // Inject GTM script
    const script = document.createElement('script');
    script.innerHTML = `
      (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
      new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
      j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
      'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
      })(window,document,'script','dataLayer','${gtmContainerId}');
    `;
    document.head.appendChild(script);

    // Handle navigation events
    this.context.navigation.addEventListener('navigate', (e) => {
      if (window.dataLayer) {
        window.dataLayer.push({
          event: 'pageView',
          pageUrl: e.location.toString(),
          pagePath: e.location.pathname,
          pageTitle: document.title
        });
      }
    });

    return Promise.resolve();
  }
}
