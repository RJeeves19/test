import { BaseApplicationCustomizer } from '@microsoft/sp-application-base';
import { SPHttpClient } from '@microsoft/sp-http';

export interface IGtmExtensionProperties {
  gtmId: string;
}

export default class GtmExtension extends BaseApplicationCustomizer<IGtmExtensionProperties> {
  private dataLayer: any[] = [];

  public onInit(): Promise<void> {
    this.initializeGTM();
    this.setupNavigationEventHandling();
    return Promise.resolve();
  }

  private initializeGTM(): void {
    const gtmId = this.properties.gtmId;
    if (gtmId) {
      const script = document.createElement('script');
      script.src = `https://www.googletagmanager.com/gtm.js?id=${gtmId}`;
      script.async = true;
      document.head.appendChild(script);

      window.dataLayer = window.dataLayer || [];
      window.dataLayer.push({
        'event': 'gtm.js',
        'gtm.start': new Date().getTime(),
      });
    }
  }

  private setupNavigationEventHandling(): void {
    this.context.application.navigatedEvent.add(this, this.onNavigated);
  }

  private onNavigated(): void {
    window.dataLayer.push({
      'event': 'pageview',
      'page': {
        'url': window.location.href,
        'title': document.title,
      }
    });
  }
}
