## Tên Đề Tài

**UniShare - Ứng dụng chia sẻ đồ dùng sinh viên**

UniShare là ứng dụng mobile hỗ trợ sinh viên cho thuê, cho mượn và tìm kiếm các đồ dùng học tập, thực hành hoặc sinh hoạt trong thời gian ngắn. Ứng dụng hướng đến việc tận dụng lại những món đồ sinh viên không còn sử dụng thường xuyên, đồng thời giúp sinh viên khác tiết kiệm chi phí mua mới.

## Ý Tưởng Sản Phẩm

Trong môi trường đại học, nhiều sinh viên chỉ cần sử dụng một số đồ vật trong một khoảng thời gian ngắn, ví dụ như máy tính cầm tay, giáo trình, bộ dụng cụ thực hành, máy ảnh, áo tốt nghiệp hoặc dụng cụ thể thao. Sau khi hoàn thành môn học, kỳ thực hành hoặc sự kiện, các đồ dùng này thường bị bỏ không, trong khi những sinh viên khác vẫn có nhu cầu sử dụng và phải mua mới.

UniShare giải quyết vấn đề này bằng cách xây dựng một nền tảng kết nối sinh viên có đồ dùng nhàn rỗi với sinh viên đang cần thuê hoặc mượn. Người dùng có thể đăng bài cho thuê/cho mượn đồ dùng, tìm kiếm theo trường hoặc khu vực, nhắn tin trực tiếp với nhau, đánh giá độ uy tín sau giao dịch và sử dụng đặt cọc trực tuyến để giảm rủi ro.

Mục tiêu của sản phẩm là:

- Giúp sinh viên tiết kiệm chi phí mua sắm đồ dùng ngắn hạn.
- Tận dụng lại tài sản đang bị bỏ không trong cộng đồng sinh viên.
- Tạo môi trường chia sẻ minh bạch, có đánh giá uy tín và thông tin giao dịch rõ ràng.
- Hỗ trợ kết nối theo trường học hoặc khu vực để việc trao đổi thuận tiện hơn.

## Phạm Vi Tổng Thể

UniShare được định hướng là một ứng dụng mobile dành cho sinh viên, tập trung vào các hoạt động đăng bài, tìm kiếm, trao đổi, đánh giá và nhận thông báo liên quan đến việc thuê/mượn đồ dùng.

Phạm vi tổng thể của hệ thống gồm:

- **Người dùng sinh viên**: đăng ký, đăng nhập, cập nhật hồ sơ cá nhân, xem điểm uy tín và lịch sử tương tác.
- **Bài đăng đồ dùng**: người dùng tạo bài cho thuê hoặc cho mượn, kèm hình ảnh, mô tả, loại đồ, tag, trường học, khu vực và thông tin liên hệ/giao dịch.
- **Tìm kiếm và lọc đồ dùng**: cho phép tìm kiếm theo từ khóa, loại đồ, tag, trường học, khu vực và trạng thái bài đăng.
- **Tương tác cộng đồng**: người dùng có thể upvote, bình luận và theo dõi phản hồi trên bài đăng.
- **Nhắn tin trực tiếp**: hỗ trợ trao đổi giữa người cho thuê/cho mượn và người có nhu cầu thuê/mượn theo thời gian thực.
- **Đánh giá uy tín**: sau quá trình trao đổi hoặc giao dịch, người dùng có thể đánh giá lẫn nhau để tăng hoặc giảm điểm uy tín.
- **Thông báo**: gửi thông báo khi có upvote, bình luận, tin nhắn mới hoặc yêu cầu thuê/mượn.
- **Đặt cọc trực tuyến**: hỗ trợ cơ chế đặt cọc nhằm giảm rủi ro mất đồ hoặc hủy giao dịch, có thể triển khai ở giai đoạn sau của MVP nếu cần tích hợp thanh toán.

Các nhóm đồ dùng mục tiêu ban đầu:

- Máy tính cầm tay.
- Giáo trình, tài liệu học tập.
- Bộ dụng cụ thực hành/thí nghiệm.
- Máy ảnh, thiết bị quay chụp.
- Áo tốt nghiệp, trang phục sự kiện.
- Dụng cụ thể thao.
- Các đồ dùng học tập hoặc sinh hoạt phù hợp khác.

## Công Nghệ Sử Dụng

- **Frontend**: Flutter.
- **Backend**: ASP.NET Core Web API (.NET 8).
- **Database**: Microsoft SQL Server.
- **Realtime communication**: SignalR cho chức năng chat và thông báo thời gian thực.
- **Authentication**: JWT hoặc cơ chế xác thực tương đương phù hợp với mobile app.
- **File/Image storage**: lưu trữ ảnh bài đăng bằng local storage trong giai đoạn phát triển, có thể mở rộng sang cloud storage khi triển khai thực tế.

## Tính Năng MVP

MVP tập trung vào các chức năng cốt lõi đủ để sinh viên có thể đăng đồ, tìm đồ, trao đổi và đánh giá uy tín cơ bản.

### 1. Đăng ký, đăng nhập và hồ sơ người dùng

- Đăng ký tài khoản bằng email/số điện thoại và mật khẩu.
- Đăng nhập, đăng xuất.
- Xem và cập nhật thông tin cá nhân cơ bản.
- Hiển thị điểm uy tín ban đầu giống nhau cho tất cả người dùng mới.

### 2. Đăng bài cho thuê/cho mượn đồ dùng

- Tạo bài đăng mới với tên đồ dùng, mô tả, hình ảnh, loại đồ, tag, trường học và khu vực.
- Chọn hình thức cho thuê hoặc cho mượn.
- Cập nhật hoặc xóa bài đăng của chính mình.
- Hỗ trợ upvote và bình luận trên bài đăng.

### 3. Tìm kiếm sản phẩm

- Tìm kiếm theo ký tự/từ khóa.
- Lọc theo loại đồ, tag, trường học hoặc khu vực.
- Xem danh sách bài đăng và chi tiết từng món đồ.

### 4. Chat giữa người dùng

- Nhắn tin trực tiếp giữa người đăng bài và người quan tâm.
- Hỗ trợ realtime message bằng SignalR.
- Lưu lịch sử hội thoại cơ bản.

### 5. Đánh giá và xếp hạng uy tín

- Người dùng có thể đánh giá người khác sau khi trao đổi/giao dịch.
- Điểm đánh giá ban đầu của các tài khoản là bằng nhau.
- Điểm uy tín tăng hoặc giảm dựa trên đánh giá từ người dùng khác.
- Hiển thị điểm uy tín trên hồ sơ và thông tin người đăng bài.

### 6. Thông báo

- Thông báo khi bài đăng có upvote mới.
- Thông báo khi có bình luận mới.
- Thông báo khi có tin nhắn mới.
- Thông báo khi có yêu cầu thuê/mượn đồ dùng.

### 7. Yêu cầu thuê/mượn và đặt cọc cơ bản

- Người dùng gửi yêu cầu thuê hoặc mượn đồ từ bài đăng.
- Chủ bài đăng có thể chấp nhận hoặc từ chối yêu cầu.
- Ghi nhận trạng thái giao dịch cơ bản: đang chờ, đã chấp nhận, đang thuê/mượn, hoàn tất, đã hủy.
- Thiết kế luồng đặt cọc trực tuyến ở mức nền tảng, có thể tích hợp cổng thanh toán ở giai đoạn phát triển tiếp theo.
