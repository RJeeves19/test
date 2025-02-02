import { IPropertyPaneConfiguration } from '@microsoft/sp-property-pane';

export const PropertyPaneConfiguration: IPropertyPaneConfiguration = {
  pages: [
    {
      header: {
        description: "Google Tag Manager Configuration"
      },
      groups: [
        {
          groupName: "Settings",
          groupFields: [
            {
              type: "textField",
              targetProperty: "gtmId",
              label: "Google Tag Manager ID",
              placeholder: "Enter your GTM ID"
            }
          ]
        }
      ]
    }
  ]
};
