# Hướng Dẫn Triển Khai Admin App (Tuần 1)

Tài liệu này cung cấp hướng dẫn chi tiết về việc triển khai hệ thống **Admin Authentication** và **Quản lý Sản phẩm/Danh mục** cho ứng dụng Admin và Backend.

## 1. Tổng quan Kiến trúc

Kiến trúc sử dụng **Firebase Authentication** và **Firestore** để quản lý người dùng/vai trò và dữ liệu sản phẩm/danh mục.

| Thành phần | Công nghệ | Vai trò |
| :--- | :--- | :--- |
| **Admin App** | Flutter/Dart | Giao diện người dùng, logic CRUD, Upload ảnh lên Firebase Storage. |
| **Firebase Auth** | Google | Quản lý thông tin đăng nhập (Email/Password). |
| **Firestore** | Google | Lưu trữ vai trò (`role: 'admin'`), Sản phẩm (`products`), Danh mục (`categories`). |
| **Firebase Storage** | Google | Lưu trữ hình ảnh sản phẩm. |
| **Backend** | Node.js/Express | Xác thực `idToken`, kiểm tra vai trò Admin, cung cấp các API bảo mật cho CRUD. |

## 2. Cấu trúc Thư mục

Mã nguồn đã được tích hợp vào cấu trúc dự án hiện tại của bạn.

### Backend (Node.js/Express)

| Đường dẫn | Mục đích |
| :--- | :--- |
| `src/controllers/productController.js` | Xử lý logic CRUD Sản phẩm. |
| `src/controllers/categoryController.js` | Xử lý logic CRUD Danh mục. |
| `src/routes/productRoutes.js` | Định nghĩa route `/api/products`. |
| `src/routes/categoryRoutes.js` | Định nghĩa route `/api/categories`. |
| *Các file Auth* | Giữ nguyên chức năng xác thực và phân quyền. |

### Admin App (Flutter)

| Đường dẫn | Mục đích |
| :--- | :--- |
| `lib/admin_app/services/product_service.dart` | Logic giao tiếp với Firestore và Firebase Storage cho Sản phẩm. |
| `lib/admin_app/services/category_service.dart` | Logic giao tiếp với Firestore cho Danh mục. |
| `lib/admin_app/screens/admin_home_screen.dart` | Dashboard mới với Bottom Navigation Bar. |
| `lib/admin_app/screens/product_management_screen.dart` | Màn hình danh sách và quản lý Sản phẩm. |
| `lib/admin_app/screens/product_form_screen.dart` | Màn hình Thêm/Sửa Sản phẩm (bao gồm chọn ảnh). |
| `lib/admin_app/screens/category_management_screen.dart` | Màn hình quản lý Danh mục. |

## 3. Hướng dẫn Triển khai Backend (Node.js/Express)

### 3.1. Cài đặt và Khởi động

1.  **Di chuyển vào thư mục Backend:** `cd Mobile-Device-Programming/backend`
2.  **Cài đặt Dependencies:** `npm install`
3.  **Cấu hình Firebase Admin SDK:** Đảm bảo file `serviceAccountKey.json` đã được đặt trong thư mục `backend/`.
4.  **Khởi động Server:** `node server.js`

### 3.2. Tài liệu API (Backend)

| Endpoint | Phương thức | Mô tả | Phân quyền |
| :--- | :--- | :--- | :--- |
| `/api/auth/login` | `POST` | Xác thực ID Token và kiểm tra vai trò Admin. | Public |
| `/api/products` | `GET` | Lấy danh sách Sản phẩm. | Public |
| `/api/products` | `POST` | Thêm Sản phẩm mới. | Admin (Yêu cầu `Bearer Token`) |
| `/api/products/:id` | `PUT` | Cập nhật Sản phẩm. | Admin (Yêu cầu `Bearer Token`) |
| `/api/products/:id` | `DELETE` | Xóa Sản phẩm. | Admin (Yêu cầu `Bearer Token`) |
| `/api/categories` | `GET` | Lấy danh sách Danh mục. | Public |
| `/api/categories` | `POST` | Thêm Danh mục mới. | Admin (Yêu cầu `Bearer Token`) |
| `/api/categories/:id` | `DELETE` | Xóa Danh mục. | Admin (Yêu cầu `Bearer Token`) |

## 4. Hướng dẫn Triển khai Admin App (Flutter)

### 4.1. Cập nhật Dependencies

Tôi đã thêm các thư viện cần thiết vào `pubspec.yaml`:
```yaml
  firebase_storage: ^11.5.6
  image_picker: ^1.0.7
```
Bạn cần chạy lệnh `flutter pub get` trong thư mục gốc của dự án để tải các thư viện này.

### 4.2. Logic Quản lý Sản phẩm

*   **Upload ảnh:** Hàm `uploadImage` trong `product_service.dart` sử dụng `firebase_storage` để tải ảnh lên và trả về URL.
*   **CRUD:** Các hàm `addProduct`, `updateProduct`, `deleteProduct` sử dụng Firestore để quản lý dữ liệu sản phẩm.
*   **Giao diện:** `product_management_screen.dart` hiển thị danh sách sản phẩm theo thời gian thực (`StreamBuilder`). `product_form_screen.dart` xử lý việc chọn ảnh (`image_picker`) và lưu/cập nhật sản phẩm.

### 4.3. Logic Quản lý Danh mục

*   **CRUD:** `category_service.dart` sử dụng Firestore để quản lý collection `categories`.
*   **Giao diện:** `category_management_screen.dart` cho phép thêm và xóa danh mục đơn giản.

## 5. Các Bước Tiếp Theo

1.  **Cài đặt Dependencies** cho Flutter: `flutter pub get`
2.  **Cấu hình Firebase Admin SDK** cho Backend (file `serviceAccountKey.json`).
3.  **Tạo dữ liệu mẫu** cho Danh mục (`categories`) và Sản phẩm (`products`) trong Firestore để kiểm tra.
4.  **Chạy Backend** và **Admin App** để kiểm tra tính năng.
