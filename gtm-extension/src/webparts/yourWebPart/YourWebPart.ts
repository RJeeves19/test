import { BaseApplicationCustomizer } from '@microsoft/sp-application-base';
import { Log } from '@microsoft/sp-core-library';

const LOG_SOURCE: string = 'YourWebPart';

export interface IYourWebPartProperties {
  gtmId: string;
}

export default class YourWebPart extends BaseApplicationCustomizer<IYourWebPartProperties> {
  
  private dataLayer: any[] = [];

  public onInit(): Promise<void> {
    this.initializeGoogleTagManager();
    this.setupDataLayer();
    this.handleNavigationEvents();
    return Promise.resolve();
  }

  private initializeGoogleTagManager(): void {
    const gtmId: string = this.properties.gtmId;
    if (gtmId) {
      const gtmScript: string = `
        <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
        new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
        j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
        'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
        })(window,document,'script','dataLayer','${gtmId}');</script>
      `;
      document.head.insertAdjacentHTML('beforeend', gtmScript);
    } else {
      Log.warn(LOG_SOURCE, 'Google Tag Manager ID is not defined.');
    }
  }

  private setupDataLayer(): void {
    window.dataLayer = window.dataLayer || [];
    this.dataLayer.push({
      'event': 'pageview',
      'pagePath': window.location.pathname,
      'pageTitle': document.title
    });
  }

  private handleNavigationEvents(): void {
    // Implement navigation event handling logic here
  }
}
