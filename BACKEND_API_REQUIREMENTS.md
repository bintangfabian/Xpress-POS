# Backend API Requirements for Sales Page

This document outlines the API endpoints that need to be implemented on the backend (Laravel) to support the Sales Page functionality in the Flutter POS application.

## Table of Contents
1. [Cash Session Management](#cash-session-management)
2. [Sales Recap](#sales-recap)
3. [Best Sellers](#best-sellers)
4. [Sales Summary](#sales-summary)
5. [Database Schema Recommendations](#database-schema-recommendations)

---

## Cash Session Management

### 1. Get Current Cash Session
**Endpoint:** `GET /api/v1/cash-sessions/current`

**Headers:**
- `Authorization: Bearer {token}`
- `X-Store-Id: {store_uuid}` (optional)

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Current cash session retrieved successfully",
  "data": {
    "id": "uuid",
    "user_id": "user_uuid",
    "store_id": "store_uuid",
    "opening_balance": 1000000,
    "closing_balance": null,
    "expected_balance": 1500000,
    "cash_sales": 600000,
    "cash_expenses": 100000,
    "variance": 0,
    "status": "open",
    "opened_at": "2025-11-06T08:00:00Z",
    "closed_at": null,
    "created_at": "2025-11-06T08:00:00Z",
    "updated_at": "2025-11-06T15:30:00Z",
    "expenses": [
      {
        "id": "expense_uuid",
        "cash_session_id": "uuid",
        "amount": 50000,
        "description": "Beli air mineral",
        "category": "Supplies",
        "created_at": "2025-11-06T10:00:00Z"
      }
    ]
  }
}
```

**Response (No Active Session - 200):**
```json
{
  "success": false,
  "message": "No active cash session found",
  "data": null
}
```

**Business Logic:**
- Returns the currently active (status='open') cash session for the authenticated user and store
- `expected_balance` = `opening_balance` + `cash_sales` - `cash_expenses`
- `cash_sales` should be automatically calculated from completed orders with payment_method='cash'
- `cash_expenses` is the sum of all expenses in the session
- Include all expenses related to this cash session

---

### 2. Open Cash Session
**Endpoint:** `POST /api/v1/cash-sessions`

**Headers:**
- `Authorization: Bearer {token}`
- `X-Store-Id: {store_uuid}` (optional)

**Request Body:**
```json
{
  "opening_balance": 1000000
}
```

**Response (Success - 201):**
```json
{
  "success": true,
  "message": "Cash session opened successfully",
  "data": {
    "id": "uuid",
    "user_id": "user_uuid",
    "store_id": "store_uuid",
    "opening_balance": 1000000,
    "closing_balance": null,
    "expected_balance": 1000000,
    "cash_sales": 0,
    "cash_expenses": 0,
    "variance": 0,
    "status": "open",
    "opened_at": "2025-11-06T08:00:00Z",
    "closed_at": null,
    "created_at": "2025-11-06T08:00:00Z",
    "updated_at": "2025-11-06T08:00:00Z",
    "expenses": []
  }
}
```

**Business Logic:**
- Check if there's already an active session for this user/store
- If yes, return error "Active session already exists"
- Create new cash session with status='open'
- Set `opened_at` to current timestamp

---

### 3. Close Cash Session
**Endpoint:** `POST /api/v1/cash-sessions/{session_id}/close`

**Headers:**
- `Authorization: Bearer {token}`
- `X-Store-Id: {store_uuid}` (optional)

**Request Body:**
```json
{
  "closing_balance": 1450000
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Cash session closed successfully",
  "data": {
    "id": "uuid",
    "user_id": "user_uuid",
    "store_id": "store_uuid",
    "opening_balance": 1000000,
    "closing_balance": 1450000,
    "expected_balance": 1500000,
    "cash_sales": 600000,
    "cash_expenses": 100000,
    "variance": -50000,
    "status": "closed",
    "opened_at": "2025-11-06T08:00:00Z",
    "closed_at": "2025-11-06T17:00:00Z",
    "created_at": "2025-11-06T08:00:00Z",
    "updated_at": "2025-11-06T17:00:00Z",
    "expenses": [...]
  }
}
```

**Business Logic:**
- Verify the session belongs to the authenticated user
- Calculate `variance` = `closing_balance` - `expected_balance`
- Set status='closed'
- Set `closed_at` to current timestamp

---

### 4. Add Expense to Cash Session
**Endpoint:** `POST /api/v1/cash-sessions/{session_id}/expenses`

**Headers:**
- `Authorization: Bearer {token}`
- `X-Store-Id: {store_uuid}` (optional)

**Request Body:**
```json
{
  "amount": 50000,
  "description": "Beli air mineral",
  "category": "Supplies"
}
```

**Response (Success - 201):**
```json
{
  "success": true,
  "message": "Expense added successfully",
  "data": {
    "id": "expense_uuid",
    "cash_session_id": "uuid",
    "amount": 50000,
    "description": "Beli air mineral",
    "category": "Supplies",
    "created_at": "2025-11-06T10:00:00Z"
  }
}
```

**Business Logic:**
- Verify the session is still open (status='open')
- Add the expense to the cash_expenses table
- Update the `cash_expenses` field in the cash session (sum of all expenses)
- Update `expected_balance` accordingly

---

## Sales Recap

### 5. Get Sales Recap
**Endpoint:** `GET /api/v1/reports/sales-recap`

**Query Parameters:**
- `start_date` (required): YYYY-MM-DD
- `end_date` (required): YYYY-MM-DD

**Headers:**
- `Authorization: Bearer {token}`
- `X-Store-Id: {store_uuid}` (optional)

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Sales recap retrieved successfully",
  "data": {
    "payment_methods": [
      {
        "payment_method": "cash",
        "count": 10,
        "total_amount": 1200000
      },
      {
        "payment_method": "qris",
        "count": 12,
        "total_amount": 1380000
      },
      {
        "payment_method": "debit_card",
        "count": 5,
        "total_amount": 750000
      }
    ],
    "operation_modes": [
      {
        "operation_mode": "dine_in",
        "count": 15,
        "total_amount": 2000000
      },
      {
        "operation_mode": "take_away",
        "count": 10,
        "total_amount": 1200000
      },
      {
        "operation_mode": "delivery",
        "count": 2,
        "total_amount": 130000
      }
    ],
    "totals": {
      "total_transactions": 27,
      "total_cash": 1200000,
      "total_non_cash": 2130000,
      "grand_total": 3330000
    }
  }
}
```

**Business Logic:**
- Query orders/payments table with completed status
- Filter by date range (created_at or completed_at)
- Group by payment_method and count
- Group by operation_mode and count
- Calculate totals:
  - `total_cash` = sum of all 'cash' payments
  - `total_non_cash` = sum of all non-cash payments
  - `grand_total` = total_cash + total_non_cash

**SQL Query Example:**
```sql
-- Payment methods breakdown
SELECT 
    payment_method,
    COUNT(*) as count,
    SUM(total_amount) as total_amount
FROM orders
WHERE status = 'completed'
    AND DATE(created_at) BETWEEN ? AND ?
    AND store_id = ?
GROUP BY payment_method;

-- Operation modes breakdown
SELECT 
    operation_mode,
    COUNT(*) as count,
    SUM(total_amount) as total_amount
FROM orders
WHERE status = 'completed'
    AND DATE(created_at) BETWEEN ? AND ?
    AND store_id = ?
GROUP BY operation_mode;
```

---

## Best Sellers

### 6. Get Best Sellers
**Endpoint:** `GET /api/v1/reports/best-sellers`

**Query Parameters:**
- `start_date` (required): YYYY-MM-DD
- `end_date` (required): YYYY-MM-DD
- `limit` (optional, default=10): Number of items to return

**Headers:**
- `Authorization: Bearer {token}`
- `X-Store-Id: {store_uuid}` (optional)

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Best sellers retrieved successfully",
  "data": {
    "products": [
      {
        "product_id": 1,
        "product_name": "Ayam Goreng Dada",
        "sku": "AGD-001",
        "category_name": "Makanan",
        "total_quantity_sold": 150,
        "total_revenue": 1800000,
        "order_count": 50,
        "image": "https://..."
      },
      {
        "product_id": 2,
        "product_name": "Es Teh Manis",
        "sku": "ETM-001",
        "category_name": "Minuman",
        "total_quantity_sold": 120,
        "total_revenue": 360000,
        "order_count": 80,
        "image": "https://..."
      }
    ],
    "categories": [
      {
        "category_id": 1,
        "category_name": "Makanan",
        "total_quantity_sold": 300,
        "total_revenue": 5000000,
        "order_count": 150
      },
      {
        "category_id": 2,
        "category_name": "Minuman",
        "total_quantity_sold": 250,
        "total_revenue": 1500000,
        "order_count": 180
      }
    ]
  }
}
```

**Business Logic:**
- Query order_items joined with products and orders
- Filter by completed orders in date range
- Group by product_id and sum quantities
- Order by total_quantity_sold DESC
- Limit to requested number of items
- Similar logic for categories

**SQL Query Example:**
```sql
-- Best selling products
SELECT 
    p.id as product_id,
    p.name as product_name,
    p.sku,
    c.name as category_name,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    COUNT(DISTINCT o.id) as order_count,
    p.image
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN products p ON oi.product_id = p.id
LEFT JOIN categories c ON p.category_id = c.id
WHERE o.status = 'completed'
    AND DATE(o.created_at) BETWEEN ? AND ?
    AND o.store_id = ?
GROUP BY p.id, p.name, p.sku, c.name, p.image
ORDER BY total_quantity_sold DESC
LIMIT ?;

-- Best selling categories
SELECT 
    c.id as category_id,
    c.name as category_name,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    COUNT(DISTINCT o.id) as order_count
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN products p ON oi.product_id = p.id
JOIN categories c ON p.category_id = c.id
WHERE o.status = 'completed'
    AND DATE(o.created_at) BETWEEN ? AND ?
    AND o.store_id = ?
GROUP BY c.id, c.name
ORDER BY total_quantity_sold DESC;
```

---

## Sales Summary

### 7. Get Sales Summary
**Endpoint:** `GET /api/v1/reports/sales-summary`

**Query Parameters:**
- `start_date` (required): YYYY-MM-DD
- `end_date` (required): YYYY-MM-DD

**Headers:**
- `Authorization: Bearer {token}`
- `X-Store-Id: {store_uuid}` (optional)

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Sales summary retrieved successfully",
  "data": {
    "gross_sales": 5000000,
    "net_sales": 4500000,
    "gross_profit": 2000000,
    "net_profit": 1800000,
    "total_transactions": 150,
    "gross_profit_margin": 40.0,
    "total_revenue": 5000000,
    "total_cost": 3000000,
    "total_tax": 250000,
    "total_discount": 300000,
    "total_service_charge": 50000,
    "daily_statistics": [
      {
        "date": "2025-11-01",
        "total_sales": 320000,
        "transaction_count": 12
      },
      {
        "date": "2025-11-02",
        "total_sales": 450000,
        "transaction_count": 15
      },
      {
        "date": "2025-11-03",
        "total_sales": 380000,
        "transaction_count": 10
      }
    ]
  }
}
```

**Field Definitions:**
- `gross_sales`: Total subtotal of all orders before discounts and taxes
- `net_sales`: Total after discounts (gross_sales - total_discount)
- `gross_profit`: Revenue minus cost of goods sold
- `net_profit`: Gross profit minus expenses
- `gross_profit_margin`: (gross_profit / gross_sales) * 100
- `total_revenue`: Final total amount received from all transactions
- `total_cost`: Total cost of goods sold (from product costs)
- `total_tax`: Sum of all tax amounts
- `total_discount`: Sum of all discount amounts
- `total_service_charge`: Sum of all service charges

**Business Logic:**
- Query orders with completed status in date range
- Calculate financial metrics:
  - Gross sales from subtotals
  - Net sales after discounts
  - Profit calculations (requires product cost data)
  - Daily breakdown for charts
- Group by date for daily_statistics

**SQL Query Example:**
```sql
-- Summary totals
SELECT 
    SUM(subtotal) as gross_sales,
    SUM(subtotal - discount_amount) as net_sales,
    SUM(total_amount) as total_revenue,
    SUM(tax_amount) as total_tax,
    SUM(discount_amount) as total_discount,
    SUM(service_charge) as total_service_charge,
    COUNT(*) as total_transactions
FROM orders
WHERE status = 'completed'
    AND DATE(created_at) BETWEEN ? AND ?
    AND store_id = ?;

-- Daily statistics
SELECT 
    DATE(created_at) as date,
    SUM(total_amount) as total_sales,
    COUNT(*) as transaction_count
FROM orders
WHERE status = 'completed'
    AND DATE(created_at) BETWEEN ? AND ?
    AND store_id = ?
GROUP BY DATE(created_at)
ORDER BY date ASC;

-- Gross profit calculation (requires product costs)
SELECT 
    SUM(oi.total_price) - SUM(oi.quantity * p.cost_price) as gross_profit
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN products p ON oi.product_id = p.id
WHERE o.status = 'completed'
    AND DATE(o.created_at) BETWEEN ? AND ?
    AND o.store_id = ?;
```

---

## Database Schema Recommendations

### Cash Sessions Table
```sql
CREATE TABLE cash_sessions (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    store_id CHAR(36) NULL,
    opening_balance BIGINT NOT NULL,
    closing_balance BIGINT NULL,
    expected_balance BIGINT NOT NULL DEFAULT 0,
    cash_sales BIGINT NOT NULL DEFAULT 0,
    cash_expenses BIGINT NOT NULL DEFAULT 0,
    variance BIGINT NOT NULL DEFAULT 0,
    status ENUM('open', 'closed') NOT NULL DEFAULT 'open',
    opened_at TIMESTAMP NOT NULL,
    closed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (store_id) REFERENCES stores(id),
    INDEX idx_user_status (user_id, status),
    INDEX idx_store_status (store_id, status),
    INDEX idx_opened_at (opened_at)
);
```

### Cash Expenses Table
```sql
CREATE TABLE cash_expenses (
    id CHAR(36) PRIMARY KEY,
    cash_session_id CHAR(36) NOT NULL,
    amount BIGINT NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cash_session_id) REFERENCES cash_sessions(id) ON DELETE CASCADE,
    INDEX idx_session (cash_session_id)
);
```

### Recommendations for Existing Tables

**Orders Table - Ensure these fields exist:**
- `payment_method` (cash, qris, debit_card, credit_card, transfer)
- `operation_mode` (dine_in, take_away, delivery)
- `subtotal` (before tax and service charge)
- `tax_amount`
- `discount_amount`
- `service_charge`
- `total_amount` (final amount)
- `status` (pending, completed, cancelled)
- `store_id` (for multi-store support)

**Products Table - Ensure these fields exist:**
- `cost_price` (for profit calculations)
- `category_id` (for category-based reporting)

---

## Integration with Existing Cash Flow

### How Cash Session Integrates with Orders/Payments

1. **When an order is completed with cash payment:**
   - Update the active cash session's `cash_sales` field
   - `cash_sales` += order.total_amount

2. **When an expense is added:**
   - Create record in cash_expenses table
   - Update cash session's `cash_expenses` field
   - Recalculate `expected_balance`

3. **Expected Balance Formula:**
   ```
   expected_balance = opening_balance + cash_sales - cash_expenses
   ```

4. **Variance Calculation (on close):**
   ```
   variance = closing_balance - expected_balance
   ```
   - Positive variance: More cash than expected (good)
   - Negative variance: Less cash than expected (needs investigation)
   - Zero variance: Perfect match

### Recommended Backend Controller Structure

```php
// CashSessionController.php
class CashSessionController extends Controller
{
    public function getCurrent(Request $request) { }
    public function open(Request $request) { }
    public function close(Request $request, $sessionId) { }
    public function addExpense(Request $request, $sessionId) { }
}

// SalesReportController.php
class SalesReportController extends Controller
{
    public function salesRecap(Request $request) { }
    public function bestSellers(Request $request) { }
    public function salesSummary(Request $request) { }
}
```

---

## Error Responses

All endpoints should return consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "errors": {
    "field_name": ["Error detail"]
  }
}
```

**Common HTTP Status Codes:**
- `200`: Success
- `201`: Created
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (invalid token)
- `403`: Forbidden (insufficient permissions)
- `404`: Not Found
- `500`: Internal Server Error

---

## Testing Recommendations

1. **Test with date ranges:**
   - Single day
   - Week range
   - Month range
   - Empty date range (no data)

2. **Test with different payment methods**

3. **Test with multiple stores** (if multi-store is supported)

4. **Test cash session lifecycle:**
   - Open → Add expenses → Close
   - Try opening when one is already open (should fail)
   - Try adding expense to closed session (should fail)

5. **Test edge cases:**
   - Zero transactions
   - Very large numbers
   - Negative variance

---

## Performance Considerations

1. **Add database indexes on:**
   - `orders.created_at`
   - `orders.status`
   - `orders.store_id`
   - `order_items.product_id`
   - `cash_sessions.status`

2. **Consider caching for:**
   - Best sellers (cache for 5-10 minutes)
   - Daily statistics (cache per day)

3. **Optimize queries with:**
   - Proper joins
   - Avoiding N+1 queries
   - Using select only needed columns

---

## Notes

- All monetary values are in the smallest currency unit (e.g., cents, Rupiah without decimals)
- All timestamps should be in UTC
- The frontend will handle timezone conversion using `TimezoneHelper.toWib()`
- Store filtering is done via `X-Store-Id` header for multi-store support