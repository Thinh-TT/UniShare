# Functional Requirements

## 1. Mục tiêu tài liệu

- Mô tả yêu cầu chức năng đủ chi tiết để đội BA, Dev, Tester và UI cùng bám vào triển khai.
- Bám theo phạm vi sản phẩm trong `/docs/01-project/01-ideas-and-scope.md` và cấu trúc dữ liệu trong `/docs/02-architecture/01-database-designer.md`
- Bao phủ toàn bộ tính năng `MVP`

## 2. Phân Tích Vai Trò Người Dùng

### 2.1. Khách chưa đăng nhập

Khách chưa đăng nhập là người mở ứng dụng nhưng chưa có phiên đăng nhập hợp lệ.

Quyền chính:

- Xem danh sách bài đăng công khai.
- Xem chi tiết bài đăng công khai.
- Tìm kiếm và lọc đồ dùng theo từ khóa, loại đồ, trường học, khu vực.
- Đăng ký tài khoản mới.
- Đăng nhập vào hệ thống.

Giới hạn:

- Không được tạo bài đăng.
- Không được upvote, bình luận, gửi tin nhắn hoặc gửi yêu cầu thuê/mượn.
- Không được xem thông tin riêng tư như hội thoại, thông báo, yêu cầu thuê/mượn của người khác.

### 2.2. Sinh viên đã đăng nhập

Sinh viên đã đăng nhập là người dùng chính của UniShare. Vai trò này có thể vừa là người cần thuê/mượn, vừa là người đăng đồ cho thuê/cho mượn.

Quyền chính:

- Quản lý hồ sơ cá nhân.
- Xem điểm uy tín và số lượng đánh giá đã nhận.
- Tạo, cập nhật, đóng hoặc xóa mềm bài đăng của mình.
- Tìm kiếm, xem chi tiết, upvote và bình luận bài đăng.
- Nhắn tin với chủ bài đăng hoặc người quan tâm bài đăng.
- Gửi yêu cầu thuê/mượn đồ.
- Theo dõi trạng thái yêu cầu và giao dịch.
- Đánh giá người dùng khác sau khi giao dịch hoàn tất.
- Nhận và đọc thông báo.

Giới hạn:

- Không được chỉnh sửa bài đăng, bình luận, yêu cầu hoặc tin nhắn của người khác.
- Không được tự gửi yêu cầu thuê/mượn bài đăng của chính mình.
- Không được đánh giá người dùng khác nếu chưa có giao dịch hoàn tất.
- Không được tạo nhiều yêu cầu đang chờ cho cùng một bài đăng.

### 2.3. Chủ bài đăng

Chủ bài đăng là sinh viên đã đăng nhập và đã tạo một bài đăng cho thuê/cho mượn.

Quyền chính:

- Quản lý nội dung bài đăng của mình.
- Xem danh sách yêu cầu thuê/mượn gửi đến bài đăng của mình.
- Chấp nhận hoặc từ chối yêu cầu thuê/mượn.
- Chat với người quan tâm hoặc người gửi yêu cầu.
- Cập nhật trạng thái giao dịch.
- Đánh giá người thuê/mượn sau khi giao dịch hoàn tất.

Giới hạn:

- Không được chấp nhận yêu cầu nếu bài đăng không còn ở trạng thái phù hợp.
- Không được thay đổi trạng thái giao dịch không liên quan đến bài đăng của mình.

### 2.4. Người thuê/mượn

Người thuê/mượn là sinh viên gửi yêu cầu thuê/mượn một bài đăng của người khác.

Quyền chính:

- Gửi yêu cầu thuê/mượn.
- Hủy yêu cầu khi yêu cầu chưa được xử lý hoặc chưa bắt đầu giao dịch.
- Chat với chủ bài đăng.
- Theo dõi trạng thái yêu cầu, đặt cọc và giao dịch.
- Xác nhận hoàn tất giao dịch theo luồng được hệ thống hỗ trợ.
- Đánh giá chủ bài đăng sau khi giao dịch hoàn tất.

Giới hạn:

- Không được gửi yêu cầu cho bài đăng của chính mình.
- Không được gửi yêu cầu cho bài đăng đã bị ẩn, xóa, đóng hoặc không còn khả dụng.

### 2.5. Quản trị viên

Quản trị viên không phải trọng tâm của MVP mobile, nhưng cần có ở mức hệ thống để quản lý dữ liệu nền.

Quyền chính:

- Quản lý danh mục đồ dùng.
- Quản lý danh sách trường học và khu vực.
- Ẩn bài đăng hoặc khóa tài khoản vi phạm nếu cần.
- Kiểm tra dữ liệu giao dịch, đánh giá và đặt cọc khi có tranh chấp.

Giới hạn:

- Không can thiệp thủ công vào điểm uy tín hoặc trạng thái đặt cọc nếu không có lý do nghiệp vụ rõ ràng.

## 3. Danh Sách Use Case

| Mã | Tên use case | Vai trò chính | Mức ưu tiên | Bảng dữ liệu liên quan |
| --- | --- | --- | --- | --- |
| `FR-001` | Đăng ký tài khoản | Khách chưa đăng nhập | Must Have | `Users` |
| `FR-002` | Đăng nhập, đăng xuất | Khách chưa đăng nhập, Sinh viên | Must Have | `Users` |
| `FR-003` | Xem và cập nhật hồ sơ cá nhân | Sinh viên | Must Have | `Users`, `Schools`, `Areas` |
| `FR-004` | Xem hồ sơ và điểm uy tín người dùng | Sinh viên, Khách | Must Have | `Users`, `Reviews` |
| `FR-005` | Tạo bài đăng cho thuê/cho mượn | Sinh viên | Must Have | `Listings`, `ListingImages`, `ListingTags`, `Tags` |
| `FR-006` | Cập nhật, đóng hoặc xóa mềm bài đăng | Chủ bài đăng | Must Have | `Listings`, `ListingImages`, `ListingTags` |
| `FR-007` | Quản lý ảnh bài đăng | Chủ bài đăng | Must Have | `ListingImages` |
| `FR-008` | Gắn loại đồ, tag, trường và khu vực cho bài đăng | Chủ bài đăng | Must Have | `Categories`, `Tags`, `Schools`, `Areas`, `ListingTags` |
| `FR-009` | Xem danh sách và chi tiết bài đăng | Khách, Sinh viên | Must Have | `Listings`, `ListingImages`, `Users` |
| `FR-010` | Tìm kiếm và lọc đồ dùng | Khách, Sinh viên | Must Have | `Listings`, `Categories`, `Tags`, `Schools`, `Areas` |
| `FR-011` | Upvote hoặc hủy upvote bài đăng | Sinh viên | Should Have | `Upvotes`, `Listings`, `Notifications` |
| `FR-012` | Bình luận và phản hồi bình luận | Sinh viên | Should Have | `Comments`, `Listings`, `Notifications` |
| `FR-013` | Tạo hoặc mở hội thoại | Sinh viên | Must Have | `Conversations`, `Listings`, `Users` |
| `FR-014` | Gửi và nhận tin nhắn realtime | Sinh viên | Must Have | `Messages`, `Conversations`, `Notifications` |
| `FR-015` | Gửi yêu cầu thuê/mượn | Người thuê/mượn | Must Have | `RentalRequests`, `Deposits`, `Notifications` |
| `FR-016` | Chấp nhận, từ chối hoặc hủy yêu cầu | Chủ bài đăng, Người thuê/mượn | Must Have | `RentalRequests`, `Listings`, `Notifications` |
| `FR-017` | Theo dõi trạng thái giao dịch | Chủ bài đăng, Người thuê/mượn | Must Have | `RentalRequests`, `Deposits` |
| `FR-018` | Ghi nhận đặt cọc cơ bản | Chủ bài đăng, Người thuê/mượn | Should Have | `Deposits`, `RentalRequests` |
| `FR-019` | Hoàn tất giao dịch thuê/mượn | Chủ bài đăng, Người thuê/mượn | Must Have | `RentalRequests`, `Listings`, `Deposits` |
| `FR-020` | Đánh giá và cập nhật điểm uy tín | Chủ bài đăng, Người thuê/mượn | Must Have | `Reviews`, `Users`, `Notifications` |
| `FR-021` | Nhận, xem và đánh dấu đã đọc thông báo | Sinh viên | Must Have | `Notifications` |
| `FR-022` | Quản lý dữ liệu nền | Quản trị viên | Should Have | `Schools`, `Areas`, `Categories`, `Tags` |

## 4. Use Case Chi Tiết

### FR-001. Đăng ký tài khoản

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Khách chưa đăng nhập |
| Mục tiêu | Tạo tài khoản sinh viên để sử dụng các chức năng cá nhân hóa |
| Điều kiện trước | Email hoặc số điện thoại chưa tồn tại trong hệ thống |
| Kết quả thành công | Tạo bản ghi `Users`, điểm uy tín mặc định là `100.00` |

Luồng chính:

1. Người dùng mở màn hình đăng ký.
2. Người dùng nhập email hoặc số điện thoại, mật khẩu và họ tên.
3. Hệ thống kiểm tra dữ liệu bắt buộc và định dạng hợp lệ.
4. Hệ thống kiểm tra email/số điện thoại chưa bị trùng.
5. Hệ thống hash mật khẩu và tạo tài khoản.
6. Hệ thống chuyển người dùng sang trạng thái đã đăng nhập hoặc yêu cầu đăng nhập lại.

Ngoại lệ:

- Email/số điện thoại đã tồn tại: hiển thị lỗi và không tạo tài khoản.
- Mật khẩu không đạt yêu cầu: yêu cầu nhập lại.
- Dữ liệu bắt buộc bị thiếu: hiển thị lỗi tương ứng.

### FR-002. Đăng nhập, đăng xuất

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Khách chưa đăng nhập, Sinh viên |
| Mục tiêu | Tạo hoặc kết thúc phiên sử dụng ứng dụng |
| Điều kiện trước | Tài khoản tồn tại và đang hoạt động |
| Kết quả thành công | Người dùng có token/phiên hợp lệ hoặc được đăng xuất an toàn |

Luồng chính:

1. Người dùng nhập email/số điện thoại và mật khẩu.
2. Hệ thống kiểm tra tài khoản tồn tại, đang hoạt động và mật khẩu hợp lệ.
3. Hệ thống cấp token đăng nhập cho mobile app.
4. Khi đăng xuất, hệ thống xóa token phía client hoặc vô hiệu hóa refresh token nếu có.

Ngoại lệ:

- Sai thông tin đăng nhập: thông báo lỗi chung, không tiết lộ tài khoản có tồn tại hay không.
- Tài khoản bị khóa hoặc inactive: từ chối đăng nhập.

### FR-003. Xem và cập nhật hồ sơ cá nhân

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Sinh viên |
| Mục tiêu | Quản lý thông tin cá nhân, trường học và khu vực |
| Điều kiện trước | Người dùng đã đăng nhập |
| Kết quả thành công | Cập nhật dữ liệu trong `Users` |

Luồng chính:

1. Người dùng mở màn hình hồ sơ cá nhân.
2. Hệ thống hiển thị họ tên, avatar, email, số điện thoại, trường, khu vực và điểm uy tín.
3. Người dùng chỉnh sửa thông tin được phép.
4. Hệ thống kiểm tra trường/khu vực còn active.
5. Hệ thống lưu thay đổi và cập nhật `UpdatedAt`.

Ngoại lệ:

- Trường hoặc khu vực không tồn tại/đã inactive: từ chối cập nhật.
- Email/số điện thoại mới bị trùng: từ chối cập nhật.

### FR-004. Xem hồ sơ và điểm uy tín người dùng

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Khách chưa đăng nhập, Sinh viên |
| Mục tiêu | Xem thông tin công khai và mức độ uy tín của người dùng |
| Điều kiện trước | Người dùng cần xem tồn tại và đang active |
| Kết quả thành công | Hiển thị hồ sơ công khai, điểm uy tín và số đánh giá |

Luồng chính:

1. Người dùng mở hồ sơ từ bài đăng, bình luận hoặc hội thoại.
2. Hệ thống hiển thị thông tin công khai: họ tên, avatar, trường, khu vực, điểm uy tín, tổng số đánh giá.
3. Nếu là chủ hồ sơ, hệ thống cho phép chuyển sang chỉnh sửa hồ sơ.

Ngoại lệ:

- Người dùng bị khóa hoặc không tồn tại: hiển thị trạng thái không khả dụng.

### FR-005. Tạo bài đăng cho thuê/cho mượn

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Sinh viên |
| Mục tiêu | Đăng đồ dùng đang nhàn rỗi để cho thuê hoặc cho mượn |
| Điều kiện trước | Người dùng đã đăng nhập và tài khoản active |
| Kết quả thành công | Tạo `Listings`, `ListingImages`, `ListingTags` nếu có |

Luồng chính:

1. Người dùng chọn tạo bài đăng mới.
2. Người dùng nhập tên đồ, mô tả, loại đồ, hình thức cho thuê/cho mượn, giá, tiền cọc, tình trạng đồ, trường, khu vực.
3. Người dùng upload ảnh và chọn tag.
4. Hệ thống kiểm tra dữ liệu hợp lệ.
5. Hệ thống lưu bài đăng ở trạng thái `Available`.
6. Bài đăng xuất hiện trong danh sách tìm kiếm công khai.

Ngoại lệ:

- Thiếu tiêu đề, mô tả, loại đồ hoặc ảnh: từ chối tạo bài.
- `ListingType = Borrow` nhưng `PricePerDay > 0`: yêu cầu sửa dữ liệu.
- Tiền cọc hoặc giá thuê âm: từ chối tạo bài.

### FR-006. Cập nhật, đóng hoặc xóa mềm bài đăng

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Chủ bài đăng |
| Mục tiêu | Quản lý vòng đời bài đăng của mình |
| Điều kiện trước | Bài đăng thuộc về người dùng đang đăng nhập |
| Kết quả thành công | Bài đăng được cập nhật, đóng hoặc set `DeletedAt` |

Luồng chính:

1. Chủ bài đăng mở màn hình quản lý bài đăng.
2. Chủ bài đăng sửa thông tin hoặc chọn đóng/xóa bài.
3. Hệ thống kiểm tra quyền sở hữu.
4. Hệ thống lưu thay đổi.
5. Nếu xóa mềm, bài đăng không còn xuất hiện trong tìm kiếm công khai.

Ngoại lệ:

- Bài đăng đang có giao dịch `InProgress`: không cho xóa hoặc đóng tùy rule sản phẩm.
- Người dùng không phải chủ bài đăng: từ chối thao tác.

### FR-007. Quản lý ảnh bài đăng

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Chủ bài đăng |
| Mục tiêu | Thêm, xóa, sắp xếp và chọn ảnh đại diện cho bài đăng |
| Điều kiện trước | Bài đăng thuộc về người dùng |
| Kết quả thành công | Cập nhật `ListingImages` |

Luồng chính:

1. Chủ bài đăng mở phần quản lý ảnh.
2. Người dùng thêm ảnh mới, xóa ảnh cũ hoặc đổi ảnh cover.
3. Hệ thống kiểm tra số lượng ảnh.
4. Hệ thống đảm bảo chỉ có một ảnh cover.
5. Hệ thống lưu thứ tự hiển thị.

Ngoại lệ:

- Vượt quá 10 ảnh: từ chối upload thêm.
- Xóa ảnh cover cuối cùng mà không chọn ảnh thay thế: yêu cầu chọn cover mới.

### FR-008. Gắn loại đồ, tag, trường và khu vực cho bài đăng

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Chủ bài đăng |
| Mục tiêu | Giúp bài đăng được phân loại và tìm kiếm chính xác |
| Điều kiện trước | Category, school, area đang active nếu được chọn |
| Kết quả thành công | Bài đăng có dữ liệu phân loại hợp lệ |

Luồng chính:

1. Người dùng chọn loại đồ từ `Categories`.
2. Người dùng chọn trường, khu vực và nhập tag.
3. Hệ thống chuẩn hóa tag và tạo tag mới nếu chưa tồn tại.
4. Hệ thống tạo liên kết trong `ListingTags`.

Ngoại lệ:

- Category inactive: không cho chọn.
- Tag trùng trong cùng bài đăng: chỉ lưu một lần.
- Quá số lượng tag cho phép: yêu cầu giảm tag.

### FR-009. Xem danh sách và chi tiết bài đăng

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Khách chưa đăng nhập, Sinh viên |
| Mục tiêu | Khám phá các đồ dùng đang có thể thuê/mượn |
| Điều kiện trước | Có bài đăng `Available` |
| Kết quả thành công | Hiển thị danh sách hoặc chi tiết bài đăng |

Luồng chính:

1. Người dùng mở trang danh sách bài đăng.
2. Hệ thống tải các bài đăng `Available`, chưa bị xóa.
3. Người dùng chọn một bài đăng.
4. Hệ thống hiển thị ảnh, mô tả, giá, tiền cọc, tag, trường, khu vực, chủ bài đăng, điểm uy tín, upvote và bình luận.
5. Hệ thống có thể tăng `ViewCount`.

Ngoại lệ:

- Bài đăng đã bị đóng/xóa/ẩn: hiển thị thông báo không khả dụng.

### FR-010. Tìm kiếm và lọc đồ dùng

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Khách chưa đăng nhập, Sinh viên |
| Mục tiêu | Tìm nhanh đồ dùng phù hợp theo nhu cầu |
| Điều kiện trước | Không bắt buộc đăng nhập |
| Kết quả thành công | Trả về danh sách bài đăng thỏa điều kiện |

Luồng chính:

1. Người dùng nhập từ khóa hoặc chọn bộ lọc.
2. Hệ thống lọc theo tiêu đề, mô tả, loại đồ, tag, trường, khu vực, hình thức thuê/mượn.
3. Hệ thống chỉ trả về bài đăng `Available` và `DeletedAt IS NULL`.
4. Người dùng có thể sắp xếp theo mới nhất, gần khu vực, nhiều upvote hoặc giá.

Ngoại lệ:

- Không có kết quả: hiển thị trạng thái rỗng và gợi ý đổi bộ lọc.

### FR-011. Upvote hoặc hủy upvote bài đăng

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Sinh viên |
| Mục tiêu | Thể hiện sự quan tâm hoặc đánh dấu bài đăng hữu ích |
| Điều kiện trước | Người dùng đã đăng nhập, bài đăng đang khả dụng |
| Kết quả thành công | Tạo hoặc xóa `Upvotes`, cập nhật `UpvoteCount` |

Luồng chính:

1. Người dùng bấm upvote trên bài đăng.
2. Nếu chưa upvote, hệ thống tạo bản ghi `Upvotes`.
3. Nếu đã upvote, hệ thống hủy upvote.
4. Hệ thống cập nhật `Listings.UpvoteCount`.
5. Nếu là upvote mới, chủ bài đăng nhận thông báo.

Ngoại lệ:

- Bài đăng đã bị xóa/ẩn: từ chối upvote.
- Người dùng chưa đăng nhập: yêu cầu đăng nhập.

### FR-012. Bình luận và phản hồi bình luận

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Sinh viên |
| Mục tiêu | Trao đổi công khai dưới bài đăng |
| Điều kiện trước | Người dùng đã đăng nhập, bài đăng chưa bị xóa |
| Kết quả thành công | Tạo `Comments`, cập nhật `CommentCount` |

Luồng chính:

1. Người dùng nhập bình luận hoặc phản hồi một bình luận.
2. Hệ thống kiểm tra nội dung không rỗng.
3. Nếu là phản hồi, hệ thống kiểm tra bình luận cha thuộc cùng bài đăng.
4. Hệ thống lưu bình luận.
5. Chủ bài đăng hoặc người liên quan nhận thông báo.

Ngoại lệ:

- Nội dung rỗng hoặc quá dài: từ chối lưu.
- Bình luận cha không hợp lệ: từ chối phản hồi.

### FR-013. Tạo hoặc mở hội thoại

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Sinh viên |
| Mục tiêu | Mở kênh trao đổi riêng về một bài đăng |
| Điều kiện trước | Người dùng đã đăng nhập và không phải chủ bài đăng |
| Kết quả thành công | Tạo hoặc lấy `Conversations` hiện có |

Luồng chính:

1. Người dùng bấm chat từ chi tiết bài đăng.
2. Hệ thống kiểm tra bài đăng còn khả dụng.
3. Hệ thống tìm hội thoại theo `ListingId`, `OwnerId`, `RequesterId`.
4. Nếu chưa có, hệ thống tạo hội thoại mới.
5. Ứng dụng mở màn hình chat.

Ngoại lệ:

- Người dùng là chủ bài đăng: không tạo hội thoại với chính mình.
- Bài đăng không khả dụng: từ chối tạo hội thoại mới.

### FR-014. Gửi và nhận tin nhắn realtime

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Sinh viên |
| Mục tiêu | Nhắn tin trực tiếp theo thời gian thực |
| Điều kiện trước | Người dùng thuộc hội thoại |
| Kết quả thành công | Lưu `Messages`, gửi realtime qua SignalR, tạo thông báo nếu cần |

Luồng chính:

1. Người dùng nhập tin nhắn.
2. Hệ thống kiểm tra người gửi thuộc hội thoại.
3. Hệ thống lưu tin nhắn vào `Messages`.
4. Hệ thống cập nhật `Conversations.LastMessageAt`.
5. Hệ thống gửi tin nhắn realtime đến người nhận.
6. Nếu người nhận không online hoặc không mở hội thoại, hệ thống tạo thông báo.

Ngoại lệ:

- Nội dung rỗng hoặc quá dài: từ chối gửi.
- Người gửi không thuộc hội thoại: từ chối truy cập.

### FR-015. Gửi yêu cầu thuê/mượn

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Người thuê/mượn |
| Mục tiêu | Gửi đề nghị thuê hoặc mượn đồ dùng |
| Điều kiện trước | Người dùng đã đăng nhập, bài đăng đang `Available` |
| Kết quả thành công | Tạo `RentalRequests` ở trạng thái `Pending` |

Luồng chính:

1. Người dùng chọn yêu cầu thuê/mượn từ bài đăng.
2. Người dùng nhập ngày bắt đầu, ngày kết thúc và lời nhắn nếu có.
3. Hệ thống kiểm tra người gửi không phải chủ bài đăng.
4. Hệ thống tính `TotalPrice` và `DepositAmount`.
5. Hệ thống tạo yêu cầu `Pending`.
6. Nếu có đặt cọc, hệ thống tạo `Deposits` với trạng thái `Pending`.
7. Chủ bài đăng nhận thông báo.

Ngoại lệ:

- Người dùng đã có yêu cầu `Pending` cho cùng bài đăng: không tạo thêm.
- Ngày bắt đầu lớn hơn ngày kết thúc: từ chối gửi.
- Bài đăng không còn khả dụng: từ chối gửi.

### FR-016. Chấp nhận, từ chối hoặc hủy yêu cầu

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Chủ bài đăng, Người thuê/mượn |
| Mục tiêu | Xử lý yêu cầu thuê/mượn |
| Điều kiện trước | Yêu cầu tồn tại và đang ở trạng thái phù hợp |
| Kết quả thành công | Cập nhật `RentalRequests`, `Listings`, `Notifications` |

Luồng chính:

1. Chủ bài đăng mở danh sách yêu cầu.
2. Chủ bài đăng chấp nhận hoặc từ chối yêu cầu `Pending`.
3. Nếu chấp nhận, hệ thống cập nhật yêu cầu sang `Accepted`.
4. Hệ thống chuyển bài đăng sang `Reserved` hoặc `InUse` tùy giai đoạn giao dịch.
5. Hệ thống thông báo kết quả cho người gửi yêu cầu.
6. Người thuê/mượn có thể hủy yêu cầu nếu trạng thái còn cho phép.

Ngoại lệ:

- Người thao tác không phải chủ bài đăng hoặc người gửi yêu cầu: từ chối.
- Yêu cầu đã hoàn tất/hủy/từ chối: không cho cập nhật lại.

### FR-017. Theo dõi trạng thái giao dịch

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Chủ bài đăng, Người thuê/mượn |
| Mục tiêu | Theo dõi tiến trình từ yêu cầu đến hoàn tất |
| Điều kiện trước | Người dùng liên quan đến yêu cầu |
| Kết quả thành công | Hiển thị trạng thái mới nhất của yêu cầu và đặt cọc |

Luồng chính:

1. Người dùng mở danh sách yêu cầu hoặc chi tiết giao dịch.
2. Hệ thống hiển thị trạng thái `Pending`, `Accepted`, `Rejected`, `Cancelled`, `InProgress`, `Completed`.
3. Nếu có đặt cọc, hệ thống hiển thị trạng thái cọc.
4. Người dùng xem lịch sử thời gian tạo/cập nhật.

Ngoại lệ:

- Người dùng không liên quan đến yêu cầu: từ chối truy cập.

### FR-018. Ghi nhận đặt cọc cơ bản

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Chủ bài đăng, Người thuê/mượn |
| Mục tiêu | Ghi nhận số tiền cọc và trạng thái cọc để giảm rủi ro |
| Điều kiện trước | Yêu cầu thuê/mượn có `DepositAmount > 0` |
| Kết quả thành công | Tạo hoặc cập nhật `Deposits` |

Luồng chính:

1. Hệ thống tạo đặt cọc `Pending` khi yêu cầu có tiền cọc.
2. Người thuê/mượn thực hiện bước xác nhận đặt cọc theo luồng MVP.
3. Hệ thống cập nhật trạng thái `Paid` khi cọc được ghi nhận.
4. Khi giao dịch hoàn tất bình thường, hệ thống cập nhật `Refunded`.
5. Nếu phát sinh vi phạm, hệ thống có thể cập nhật `Forfeited`.

Ngoại lệ:

- Không có tiền cọc: không tạo bản ghi đặt cọc.
- Hoàn cọc khi chưa `Paid`: từ chối thao tác.

### FR-019. Hoàn tất giao dịch thuê/mượn

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Chủ bài đăng, Người thuê/mượn |
| Mục tiêu | Kết thúc giao dịch và mở quyền đánh giá |
| Điều kiện trước | Yêu cầu đang `Accepted` hoặc `InProgress` |
| Kết quả thành công | Cập nhật yêu cầu `Completed`, bài đăng có thể quay lại `Available` hoặc `Closed` |

Luồng chính:

1. Một bên xác nhận giao dịch đã hoàn tất.
2. Hệ thống kiểm tra quyền và trạng thái hiện tại.
3. Hệ thống cập nhật `RentalRequests.Status = Completed`.
4. Nếu đồ còn tiếp tục cho thuê/mượn, bài đăng quay lại `Available`.
5. Nếu chủ bài đăng muốn kết thúc bài, bài đăng chuyển sang `Closed`.
6. Nếu có cọc đã thanh toán, hệ thống xử lý hoàn cọc theo rule.

Ngoại lệ:

- Giao dịch chưa được chấp nhận: không cho hoàn tất.
- Người dùng không liên quan đến giao dịch: từ chối thao tác.

### FR-020. Đánh giá và cập nhật điểm uy tín

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Chủ bài đăng, Người thuê/mượn |
| Mục tiêu | Ghi nhận chất lượng giao dịch và cập nhật uy tín người dùng |
| Điều kiện trước | Giao dịch đã `Completed` |
| Kết quả thành công | Tạo `Reviews`, cập nhật `Users.ReputationScore` và `TotalReviews` |

Luồng chính:

1. Người dùng mở màn hình đánh giá sau giao dịch.
2. Người dùng chọn điểm `1` đến `5` và nhập bình luận nếu có.
3. Hệ thống kiểm tra người đánh giá thuộc giao dịch.
4. Hệ thống kiểm tra người dùng chưa đánh giá người còn lại trong giao dịch này.
5. Hệ thống lưu review và tính `ReputationDelta`.
6. Hệ thống cập nhật điểm uy tín của người được đánh giá.
7. Người được đánh giá nhận thông báo.

Ngoại lệ:

- Giao dịch chưa hoàn tất: không cho đánh giá.
- Đánh giá trùng: từ chối tạo thêm.
- Người đánh giá và người được đánh giá trùng nhau: từ chối.

### FR-021. Nhận, xem và đánh dấu đã đọc thông báo

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Sinh viên |
| Mục tiêu | Theo dõi các sự kiện liên quan đến mình |
| Điều kiện trước | Người dùng đã đăng nhập |
| Kết quả thành công | Hiển thị `Notifications`, cập nhật trạng thái đọc |

Luồng chính:

1. Hệ thống tạo thông báo khi có upvote, bình luận, tin nhắn, yêu cầu thuê/mượn, thay đổi trạng thái yêu cầu hoặc đánh giá.
2. Người dùng mở danh sách thông báo.
3. Hệ thống hiển thị thông báo mới nhất trước.
4. Người dùng mở một thông báo.
5. Hệ thống cập nhật `IsRead = 1` và `ReadAt`.

Ngoại lệ:

- Người dùng truy cập thông báo của người khác: từ chối.

### FR-022. Quản lý dữ liệu nền

| Thuộc tính | Nội dung |
| --- | --- |
| Vai trò | Quản trị viên |
| Mục tiêu | Duy trì dữ liệu nền để người dùng phân loại và tìm kiếm chính xác |
| Điều kiện trước | Tài khoản có quyền quản trị |
| Kết quả thành công | Cập nhật `Schools`, `Areas`, `Categories`, `Tags` |

Luồng chính:

1. Quản trị viên tạo hoặc cập nhật trường học, khu vực, loại đồ.
2. Hệ thống kiểm tra dữ liệu không trùng và không rỗng.
3. Nếu dữ liệu đã được sử dụng, quản trị viên chỉ nên chuyển `IsActive = 0` thay vì xóa cứng.
4. Dữ liệu active được hiển thị trong bộ lọc và form tạo bài đăng.

Ngoại lệ:

- Người dùng không có quyền quản trị: từ chối truy cập.
- Tên hoặc slug bị trùng: từ chối lưu.

## 5. Business Rules Tổng Hợp

### 5.1. Tài khoản và phân quyền

- Chỉ người dùng đã đăng nhập mới được tạo bài đăng, upvote, bình luận, chat, gửi yêu cầu thuê/mượn, đánh giá và xem thông báo cá nhân.
- Tài khoản `IsActive = 0` không được thực hiện hành động tạo mới dữ liệu nghiệp vụ.
- Email bắt buộc unique; số điện thoại unique nếu được nhập.
- Mật khẩu phải được hash, không lưu plain text.
- Người dùng chỉ được chỉnh sửa dữ liệu thuộc quyền sở hữu của mình, trừ quản trị viên.

### 5.2. Bài đăng

- Bài đăng công khai phải có trạng thái `Available` và `DeletedAt IS NULL`.
- Bài đăng bắt buộc có tiêu đề, mô tả, loại đồ, hình thức thuê/mượn và ít nhất 1 ảnh.
- Nếu bài đăng là cho mượn miễn phí (`Borrow`) thì `PricePerDay = 0`.
- Giá thuê, tiền cọc, lượt xem, upvote và comment count không được âm.
- Mỗi bài đăng chỉ có một ảnh cover.
- Một bài đăng nên có tối đa 10 ảnh và tối đa 10 tag.
- Chủ bài đăng không được gửi yêu cầu thuê/mượn bài của chính mình.

### 5.3. Tìm kiếm và tương tác cộng đồng

- Khách chưa đăng nhập được xem và tìm kiếm bài đăng công khai nhưng không được tương tác.
- Upvote là duy nhất theo cặp người dùng và bài đăng.
- Bình luận reply phải thuộc cùng bài đăng với bình luận cha.
- Khi thêm hoặc xóa mềm upvote/bình luận, hệ thống phải cập nhật lại số đếm tương ứng trên bài đăng.
- Khi có upvote hoặc bình luận mới, chủ bài đăng nhận thông báo.

### 5.4. Chat

- Một cặp `ListingId`, `OwnerId`, `RequesterId` chỉ nên có một hội thoại.
- Chỉ chủ bài đăng và người hỏi/thuê/mượn được xem hội thoại.
- Người gửi tin nhắn phải là thành viên của hội thoại.
- Nội dung tin nhắn không được rỗng.
- Khi có tin nhắn mới, hệ thống cập nhật `LastMessageAt` và gửi realtime qua SignalR nếu có kết nối.

### 5.5. Yêu cầu thuê/mượn và giao dịch

- Chỉ tạo yêu cầu thuê/mượn cho bài đăng đang `Available`.
- `RequesterId` không được trùng với `OwnerId`.
- `StartDate` phải nhỏ hơn hoặc bằng `EndDate`.
- Một người dùng không được có nhiều yêu cầu `Pending` cho cùng một bài đăng.
- Chỉ chủ bài đăng được chấp nhận hoặc từ chối yêu cầu gửi đến bài đăng của mình.
- Khi một yêu cầu được chấp nhận, MVP đề xuất tự động từ chối các yêu cầu `Pending` khác của cùng bài đăng để tránh trùng lịch.
- Chỉ người liên quan đến yêu cầu mới được xem chi tiết giao dịch.

### 5.6. Đặt cọc

- Đặt cọc là chức năng nền tảng trong MVP, có thể ghi nhận trạng thái trước khi tích hợp cổng thanh toán thật.
- Mỗi yêu cầu thuê/mượn chỉ có tối đa một bản ghi đặt cọc.
- Nếu có đặt cọc, `Amount` phải lớn hơn `0`.
- Không hoàn cọc nếu trạng thái hiện tại không phải `Paid`.
- Trạng thái `Forfeited` chỉ dùng khi có xử lý vi phạm hoặc tranh chấp.

### 5.7. Đánh giá và uy tín

- Chỉ được đánh giá sau khi giao dịch `Completed`.
- Mỗi người chỉ được đánh giá người còn lại một lần trong cùng giao dịch.
- Điểm đánh giá nằm trong khoảng `1` đến `5`.
- Điểm uy tín ban đầu của người dùng mới là `100.00`.
- Sau khi tạo review, hệ thống phải cập nhật `ReputationScore` và `TotalReviews` của người được đánh giá.
- Người dùng không được tự đánh giá chính mình.

### 5.8. Thông báo

- Thông báo được tạo khi có upvote, bình luận, tin nhắn, yêu cầu thuê/mượn, thay đổi trạng thái yêu cầu hoặc đánh giá.
- Thông báo mặc định `IsRead = 0`.
- Khi người dùng mở thông báo, hệ thống cập nhật `IsRead = 1` và `ReadAt`.
- Người dùng chỉ được xem thông báo của chính mình.

### 5.9. Dữ liệu nền

- Trường học, khu vực và loại đồ chỉ hiển thị khi `IsActive = 1`.
- Không xóa cứng dữ liệu nền đã được bài đăng hoặc người dùng tham chiếu.
- Slug của category và tag phải unique.
- Tag cần được chuẩn hóa trước khi lưu để tránh trùng biến thể do viết hoa, khoảng trắng hoặc dấu câu không cần thiết.
