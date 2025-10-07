import BasePage from './BasePage.js';

class AdminManagementPage extends BasePage {
  constructor(page) {
    super(page);
  }

  // Navigation
  async navigateToAdminManagement() {
    await this.navigateTo('/admin-management');
    await this.waitForPageLoad();
  }

  async waitForAdminManagementLoad() {
    await this.waitForElement('h1:has-text("Admin Management")');
    await this.waitForElement('[data-testid="admin-kpi-cards"]', 15000);
  }

  // Page Elements
  get pageTitle() {
    return this.page.locator('h1:has-text("Admin Management")');
  }

  get pageDescription() {
    return this.page.locator('text=This page is for Super Admins only');
  }

  // KPI Cards
  get kpiCardsSection() {
    return this.page.locator('.grid.grid-cols-1.md\\:grid-cols-2.lg\\:grid-cols-4.gap-6');
  }

  get totalAdminsCard() {
    return this.page.locator('[data-testid="kpi-card"]:has-text("Total Admins")');
  }

  get superAdminsCard() {
    return this.page.locator('[data-testid="kpi-card"]:has-text("Super Admins")');
  }

  get regularAdminsCard() {
    return this.page.locator('[data-testid="kpi-card"]:has-text("Regular Admins")');
  }

  get totalLotsCard() {
    return this.page.locator('[data-testid="kpi-card"]:has-text("Total Lots")');
  }

  // Create Admin Form
  get createAdminSection() {
    return this.page.locator('text=Create New Admin').locator('..').locator('..');
  }

  get createAdminTitle() {
    return this.page.locator('text=Create New Admin');
  }

  get nameInput() {
    return this.page.locator('input[name="name"]');
  }

  get emailInput() {
    return this.page.locator('input[name="email"]');
  }

  get passwordInput() {
    return this.page.locator('input[name="password"]');
  }

  get assignedLotsSection() {
    return this.page.locator('label:has-text("Assigned Lots")').locator('..');
  }

  get assignedLotsCheckboxes() {
    return this.page.locator('input[type="checkbox"][value]:not([value=""])');
  }

  get createAdminButton() {
    return this.page.locator('button:has-text("Create Admin")');
  }

  get createAdminButtonLoading() {
    return this.page.locator('button:has-text("Creating Admin...")');
  }

  // Form Validation Messages
  get nameError() {
    return this.page.locator('text=Name').locator('..').locator('.text-red-600');
  }

  get emailError() {
    return this.page.locator('text=Email').locator('..').locator('.text-red-600');
  }

  get passwordError() {
    return this.page.locator('text=Password').locator('..').locator('.text-red-600');
  }

  get assignedLotsError() {
    return this.page.locator('text=Assigned Lots').locator('..').locator('.text-red-600');
  }

  get submitError() {
    return this.page.locator('.bg-red-50 .text-red-600');
  }

  get submitSuccess() {
    return this.page.locator('.bg-green-50 .text-green-600');
  }

  // Existing Admins Section
  get existingAdminsSection() {
    return this.page.locator('text=Existing Admins').locator('..').locator('..');
  }

  get existingAdminsTitle() {
    return this.page.locator('text=Existing Admins');
  }

  get searchInput() {
    return this.page.locator('input[placeholder="Search admins..."]');
  }

  get adminTable() {
    return this.page.locator('table');
  }

  get adminTableHeaders() {
    return this.page.locator('table thead th');
  }

  get adminTableRows() {
    return this.page.locator('table tbody tr');
  }

  get adminTableData() {
    return this.page.locator('table tbody td');
  }

  get editButtons() {
    return this.page.locator('button:has(svg):has-text("")').filter({ hasText: '' });
  }

  get deleteButtons() {
    return this.page.locator('button:has(svg):has-text("")').filter({ hasText: '' });
  }

  // Loading States
  get loadingSpinner() {
    return this.page.locator('[data-testid="loading-spinner"]');
  }

  get loadingSkeletons() {
    return this.page.locator('[data-testid="loading-skeleton"]');
  }

  // Error States
  get errorMessage() {
    return this.page.locator('.text-red-600');
  }

  get retryButton() {
    return this.page.locator('button:has-text("Retry")');
  }

  // Modals
  get deleteModal() {
    return this.page.locator('[role="dialog"]:has-text("Delete Admin")');
  }

  get editModal() {
    return this.page.locator('[role="dialog"]:has-text("Edit Admin Lots")');
  }

  get modalConfirmButton() {
    return this.page.locator('[role="dialog"] button:has-text("Delete"), [role="dialog"] button:has-text("Save Changes")');
  }

  get modalCancelButton() {
    return this.page.locator('[role="dialog"] button:has-text("Cancel")');
  }

  get modalCloseButton() {
    return this.page.locator('[role="dialog"] button[aria-label="Close"]');
  }

  // Available Lots Information
  get availableLotsInfo() {
    return this.page.locator('text=Currently assigned lots:');
  }

  get noAvailableLotsMessage() {
    return this.page.locator('text=All parking lots are currently assigned');
  }

  // Helper Methods
  async getKPIValue(kpiTitle) {
    const card = this.page.locator(`[data-testid="kpi-card"]:has-text("${kpiTitle}")`);
    const valueElement = card.locator('[data-testid="kpi-value"]');
    return await valueElement.textContent();
  }

  async getKPIValueByIndex(index) {
    const cards = this.page.locator('[data-testid="kpi-card"]');
    const valueElement = cards.nth(index).locator('[data-testid="kpi-value"]');
    return await valueElement.textContent();
  }

  async getAdminCount() {
    const rows = await this.adminTableRows.count();
    return rows;
  }

  async getAdminByIndex(index) {
    const row = this.adminTableRows.nth(index);
    return {
      name: await row.locator('td').nth(0).textContent(),
      email: await row.locator('td').nth(1).textContent(),
      role: await row.locator('td').nth(2).textContent(),
      assignedLots: await row.locator('td').nth(3).textContent(),
      status: await row.locator('td').nth(4).textContent(),
    };
  }

  async searchAdmins(searchTerm) {
    await this.searchInput.fill(searchTerm);
    await this.page.waitForTimeout(500); // Wait for search to filter
  }

  async clearSearch() {
    await this.searchInput.clear();
    await this.page.waitForTimeout(500);
  }

  async fillCreateAdminForm(data) {
    if (data.name) {
      await this.nameInput.fill(data.name);
    }
    if (data.email) {
      await this.emailInput.fill(data.email);
    }
    if (data.password) {
      await this.passwordInput.fill(data.password);
    }
    if (data.assignedLots && data.assignedLots.length > 0) {
      for (const lotId of data.assignedLots) {
        await this.page.locator(`input[type="checkbox"][value="${lotId}"]`).check();
      }
    }
  }

  async clearCreateAdminForm() {
    await this.nameInput.clear();
    await this.emailInput.clear();
    await this.passwordInput.clear();
    // Uncheck all checkboxes
    const checkboxes = await this.assignedLotsCheckboxes.all();
    for (const checkbox of checkboxes) {
      if (await checkbox.isChecked()) {
        await checkbox.uncheck();
      }
    }
  }

  async selectAvailableLot(lotId) {
    await this.page.locator(`input[type="checkbox"][value="${lotId}"]`).check();
  }

  async unselectAvailableLot(lotId) {
    await this.page.locator(`input[type="checkbox"][value="${lotId}"]`).uncheck();
  }

  async getAvailableLots() {
    const checkboxes = await this.assignedLotsCheckboxes.all();
    const lots = [];
    for (const checkbox of checkboxes) {
      const value = await checkbox.getAttribute('value');
      const label = await checkbox.locator('..').locator('span').textContent();
      lots.push({ id: parseInt(value), label });
    }
    return lots;
  }

  async getSelectedLots() {
    const checkboxes = await this.assignedLotsCheckboxes.all();
    const selectedLots = [];
    for (const checkbox of checkboxes) {
      if (await checkbox.isChecked()) {
        const value = await checkbox.getAttribute('value');
        const label = await checkbox.locator('..').locator('span').textContent();
        selectedLots.push({ id: parseInt(value), label });
      }
    }
    return selectedLots;
  }

  async clickEditAdmin(index) {
    const editButton = this.adminTableRows.nth(index).locator('button').first();
    await editButton.click();
  }

  async clickDeleteAdmin(index) {
    const deleteButton = this.adminTableRows.nth(index).locator('button').last();
    await deleteButton.click();
  }

  async confirmDelete() {
    await this.modalConfirmButton.click();
  }

  async cancelDelete() {
    await this.modalCancelButton.click();
  }

  async closeModal() {
    await this.modalCloseButton.click();
  }

  async submitCreateAdminForm() {
    await this.createAdminButton.click();
  }

  async waitForKPICards() {
    await this.page.locator('[data-testid="kpi-card"]').first().waitFor({ timeout: 15000 });
  }

  async waitForAdminTable() {
    await this.waitForElement('table', 15000);
  }

  async waitForFormSubmission() {
    await this.page.waitForTimeout(2000); // Wait for form submission
  }

  async isFormSubmitting() {
    return await this.createAdminButtonLoading.isVisible();
  }

  async isFormDisabled() {
    return await this.createAdminButton.isDisabled();
  }

  async hasFormErrors() {
    const nameErrorVisible = await this.nameError.isVisible();
    const emailErrorVisible = await this.emailError.isVisible();
    const passwordErrorVisible = await this.passwordError.isVisible();
    const assignedLotsErrorVisible = await this.assignedLotsError.isVisible();
    return nameErrorVisible || emailErrorVisible || passwordErrorVisible || assignedLotsErrorVisible;
  }

  async hasSubmitError() {
    return await this.submitError.isVisible();
  }

  async hasSubmitSuccess() {
    return await this.submitSuccess.isVisible();
  }

  async isLoading() {
    return await this.loadingSpinner.first().isVisible() || await this.loadingSkeletons.isVisible();
  }

  async hasError() {
    return await this.errorMessage.first().isVisible();
  }

  async getErrorMessage() {
    return await this.errorMessage.textContent();
  }

  async getSubmitErrorMessage() {
    return await this.submitError.textContent();
  }

  async getSubmitSuccessMessage() {
    return await this.submitSuccess.textContent();
  }

  async getFormErrorMessages() {
    const errors = {};
    if (await this.nameError.isVisible()) {
      errors.name = await this.nameError.textContent();
    }
    if (await this.emailError.isVisible()) {
      errors.email = await this.emailError.textContent();
    }
    if (await this.passwordError.isVisible()) {
      errors.password = await this.passwordError.textContent();
    }
    if (await this.assignedLotsError.isVisible()) {
      errors.assignedLots = await this.assignedLotsError.textContent();
    }
    return errors;
  }

  async refreshAdminData() {
    await this.page.reload();
    await this.waitForAdminManagementLoad();
  }

  async waitForModal(modalType = 'delete') {
    const modal = modalType === 'delete' ? this.deleteModal : this.editModal;
    await modal.waitFor({ timeout: 5000 });
  }

  async isModalOpen(modalType = 'delete') {
    const modal = modalType === 'delete' ? this.deleteModal : this.editModal;
    return await modal.isVisible();
  }

  async getModalTitle(modalType = 'delete') {
    const modal = modalType === 'delete' ? this.deleteModal : this.editModal;
    return await modal.locator('h2, h3').textContent();
  }

  async getModalMessage(modalType = 'delete') {
    const modal = modalType === 'delete' ? this.deleteModal : this.editModal;
    return await modal.locator('p').first().textContent();
  }
}

export default AdminManagementPage;
