# SDG Starter Pack

A foundation for Sustainable Development Goal (SDG) tracking and reporting on Salesforce

SDG Starter Pack provides a set of Fields, Page Layouts, Objects, Record Types and Automation to help you get started with recording and tracking your Salesforce records against sustainable development goals.

## Installation

### Option 1: Install from AppExchange (Recommended)

The easiest way to install SDG Starter Pack is through the Salesforce AppExchange:

[Install from AppExchange](https://appexchange.salesforce.com/appxListingDetail?listingId=874d6137-448e-462e-8e25-bf17a0f3a544)

1. Click the link above or visit the AppExchange listing
2. Click "Get It Now"
3. Choose whether to install in production or sandbox
4. Log in to your Salesforce org
5. Follow the installation wizard
6. Select the appropriate installation option:
   - **Install for Admins Only** - Recommended for initial setup
   - **Install for All Users** - After configuring permissions
   - **Install for Specific Profiles** - For controlled rollout

### Option 2: Direct Installation Link

You can also install the latest package version directly using the package installation URL:

**Production:**
```
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tDm000000DaJvIAK
```

**Sandbox:**
```
https://test.salesforce.com/packaging/installPackage.apexp?p0=04tDm000000DaJvIAK
```

Replace `04t...` with the latest package version ID. Contact the maintainers for the current version ID.

## Post-Installation Setup

After installation, assign the appropriate permission sets to users:

- **SDG User Permission** - Base permissions for all users
- **SDG Admin Permission** - For administrators who can change configuration

### Assigning Permission Sets

1. Navigate to **Setup** > **Users** > **Permission Sets**
2. Select the appropriate permission set
3. Click **Manage Assignments**
4. Click **Add Assignments**
5. Select users and click **Assign**

## Features

SDG Starter Pack includes:

- SDG objects and fields
- Integration with United Nations(UN) API
- Custom page layouts and record types
- Pre-configured automation

## Contributing

Interested in contributing to SDG Starter Pack? Check out our [Contributing Guide](CONTRIBUTING.md) for information on:

- Setting up your development environment
- Creating scratch orgs
- Making and testing changes
- Submitting pull requests

## Support

For issues, questions, or feature requests:

- Open an issue in the [GitHub repository](https://github.com/SalesforceLabs/SDGStarterPack/issues)
- Contact Stewart Anderson at [stewart.anderson@salesforce.com](mailto:stewart.anderson@salesforce.com)

## License

See LICENSE.md

---

Built with ❤️ by Salesforce Labs
