# Quy Trình Xây Dựng App Với AI Agent

## 1. Mục tiêu tài liệu

Tài liệu này giải thích quy trình xây dựng ứng dụng **UniShare** bằng AI Agent theo cách dễ hiểu cho sinh viên kinh tế. Mục tiêu không phải biến người đọc thành lập trình viên ngay lập tức, mà giúp người đọc nắm được:

- Một ý tưởng kinh doanh/xã hội được chuyển thành ứng dụng như thế nào.
- AI Agent tham gia vào từng bước phát triển app ra sao.
- Con người cần chuẩn bị, kiểm tra và ra quyết định ở đâu.
- Vì sao vẫn cần tài liệu, kiểm thử và ghi log dù có AI hỗ trợ.

Ví dụ xuyên suốt là dự án **UniShare - ứng dụng chia sẻ đồ dùng sinh viên**, một app mobile giúp sinh viên đăng cho thuê/cho mượn đồ dùng, tìm kiếm theo trường hoặc khu vực, chat realtime, gửi yêu cầu thuê/mượn, đánh giá uy tín, nhận thông báo và ghi nhận đặt cọc cơ bản.

Tài liệu này nên được đọc cùng các tài liệu trong dự án:

- [Ý tưởng và phạm vi](../01-project/01-ideas-and-scope.md)
- [Yêu cầu chức năng](../03-functional/01-functional-requirements.md)
- [Thiết kế database](../02-architecture/01-database-designer.md)
- [Đặc tả API](../02-architecture/02-api-spec.md)
- [Sitemap và wireframe UI](../04-ui/01-ui-sitemap-and-wireframe.md)
- [Task board](../05-tasks/01-task-board.md)
- [Nhật ký phát triển](../06-logs/dev-log.md)

## 2. UniShare giải quyết vấn đề gì?

Trong môi trường đại học, sinh viên thường chỉ cần dùng một số món đồ trong thời gian ngắn: máy tính cầm tay, giáo trình, áo tốt nghiệp, máy ảnh, dụng cụ thể thao hoặc dụng cụ thực hành. Sau khi học xong môn hoặc kết thúc sự kiện, nhiều món đồ bị bỏ không, trong khi sinh viên khác lại phải mua mới.

UniShare giải quyết vấn đề này bằng cách tạo một nền tảng kết nối:

| Nhóm người dùng           | Nhu cầu                                           | UniShare hỗ trợ                                        |
| ------------------------- | ------------------------------------------------- | ------------------------------------------------------ |
| Sinh viên có đồ ít dùng   | Muốn cho thuê/cho mượn để tận dụng tài sản        | Đăng bài, thêm ảnh, mô tả, giá thuê/cọc                |
| Sinh viên cần đồ ngắn hạn | Muốn tìm đồ gần trường/khu vực, tiết kiệm chi phí | Tìm kiếm, lọc, chat, gửi yêu cầu thuê/mượn             |
| Hai bên giao dịch         | Muốn có thông tin rõ ràng và tin cậy              | Chat, trạng thái giao dịch, đánh giá uy tín, thông báo |

Nhìn từ góc độ sinh viên kinh tế, UniShare là một bài toán sản phẩm gồm:

- **Vấn đề thị trường**: tài sản nhàn rỗi và nhu cầu sử dụng ngắn hạn chưa được kết nối tốt.
- **Đối tượng khách hàng**: sinh viên trong cùng trường hoặc cùng khu vực.
- **Giá trị cung cấp**: tiết kiệm chi phí, tăng khả năng tận dụng tài sản, giảm rủi ro thông qua hồ sơ và đánh giá.
- **Sản phẩm MVP**: phiên bản đủ chức năng cốt lõi để người dùng có thể đăng đồ, tìm đồ, trao đổi và hoàn tất giao dịch cơ bản.

## 3. AI Agent là gì?

AI Agent là một trợ lý AI có khả năng làm việc theo mục tiêu, đọc tài liệu, phân tích code, đề xuất kế hoạch, chỉnh sửa file, chạy kiểm thử và báo cáo kết quả. Nếu chatbot thông thường chủ yếu trả lời câu hỏi, AI Agent có thể tham gia sâu hơn vào quá trình làm dự án.

| Tiêu chí          | Chatbot hỏi đáp                         | AI Agent trong dự án phần mềm                   |
| ----------------- | --------------------------------------- | ----------------------------------------------- |
| Cách làm việc     | Trả lời từng câu hỏi                    | Theo đuổi một task đến khi hoàn thành           |
| Ngữ cảnh          | Thường dựa vào nội dung người dùng nhập | Đọc tài liệu, code, log và cấu trúc dự án       |
| Kết quả           | Gợi ý, giải thích, ví dụ                | Có thể tạo/sửa file, viết test, chạy kiểm tra   |
| Vai trò con người | Hỏi và nhận câu trả lời                 | Định hướng, duyệt quyết định, kiểm tra sản phẩm |

Trong UniShare, AI Agent không chỉ viết code. Agent còn hỗ trợ:

- Biến ý tưởng thành tài liệu phạm vi.
- Chia chức năng thành use case.
- Thiết kế database, API và UI.
- Lập task board theo phase.
- Triển khai backend, app Flutter, test và sửa lỗi.
- Ghi lại quyết định kỹ thuật và bài học sau mỗi phiên làm việc.

## 4. Một số thuật ngữ kỹ thuật cần biết

Sinh viên kinh tế không cần hiểu sâu từng dòng code để nắm quy trình. Tuy vậy, cần hiểu các khái niệm chính sau:

| Thuật ngữ | Hiểu đơn giản                                | Ví dụ trong UniShare                                      |
| --------- | -------------------------------------------- | --------------------------------------------------------- |
| Backend   | Bộ phận xử lý nghiệp vụ phía sau app         | Kiểm tra đăng nhập, tạo bài đăng, xử lý yêu cầu thuê/mượn |
| Database  | Nơi lưu dữ liệu                              | Lưu người dùng, bài đăng, ảnh, tin nhắn, đánh giá         |
| API       | Cầu nối giữa app và backend                  | App gọi `GET /listings` để lấy danh sách bài đăng         |
| Flutter   | Công nghệ xây dựng giao diện mobile          | Màn hình Home, Search, Chat, Profile                      |
| SignalR   | Kênh realtime cho dữ liệu đến ngay           | Chat và thông báo mới xuất hiện tức thời                  |
| JWT       | Vé đăng nhập điện tử                         | App gửi token để backend biết người dùng là ai            |
| Test      | Cách kiểm tra app có chạy đúng kỳ vọng không | Test đăng nhập, tạo bài, gửi yêu cầu, chat                |
| MVP       | Phiên bản tối thiểu có thể dùng được         | Đủ để đăng đồ, tìm đồ, chat, thuê/mượn và đánh giá        |

## 5. Vai trò của con người và AI Agent

AI Agent giúp tăng tốc, nhưng không thay thế hoàn toàn người làm dự án. Một dự án tốt vẫn cần con người giữ vai trò chủ sản phẩm.

### Con người quyết định

- Vấn đề nào đáng giải quyết.
- Người dùng mục tiêu là ai.
- Chức năng nào nằm trong MVP, chức năng nào để sau.
- Quy tắc nghiệp vụ có hợp lý không.
- Giao diện và trải nghiệm đã phù hợp với sinh viên chưa.
- Kết quả cuối cùng có đáp ứng yêu cầu môn học hay không.

### AI Agent hỗ trợ

- Đọc và tóm tắt tài liệu.
- Đề xuất cấu trúc chức năng.
- Viết bản nháp database, API, UI và task board.
- Triển khai code theo tài liệu.
- Phát hiện lỗi, chạy test và sửa lỗi.
- Ghi lại quyết định, blocker và bài học.

Nói ngắn gọn: **con người giữ hướng đi, AI Agent hỗ trợ triển khai và kiểm tra**.

## 6. Quy trình xây dựng app với AI Agent

### Bước 1. Xác định vấn đề và người dùng mục tiêu

Trước khi nói đến công nghệ, nhóm cần trả lời ba câu hỏi:

- Ai đang gặp vấn đề?
- Vấn đề xảy ra trong hoàn cảnh nào?
- App giúp họ tốt hơn ra sao?

Với UniShare:

- Người dùng là sinh viên.
- Vấn đề là cần thuê/mượn đồ ngắn hạn hoặc có đồ nhàn rỗi muốn chia sẻ.
- App giúp kết nối hai bên, giảm chi phí mua mới và tận dụng tài sản trong cộng đồng.

AI Agent có thể hỗ trợ bằng cách biến mô tả ban đầu thành tài liệu ý tưởng, phạm vi và mục tiêu sản phẩm.

Prompt mẫu:

```text
Hãy giúp tôi phân tích ý tưởng app chia sẻ đồ dùng sinh viên.
Người dùng chính là sinh viên cần thuê/mượn đồ ngắn hạn và sinh viên có đồ không dùng thường xuyên.
Hãy viết phần vấn đề, đối tượng người dùng, giá trị mang lại và phạm vi MVP.
```

Kết quả của bước này trong UniShare là tài liệu [01-ideas-and-scope.md](../01-project/01-ideas-and-scope.md).

### Bước 2. Chuyển ý tưởng thành MVP

MVP là phiên bản đầu tiên đủ dùng để kiểm chứng ý tưởng. Với sinh viên kinh tế, có thể hiểu MVP giống như một bản sản phẩm tối thiểu để đem đi thử nghiệm thị trường.

Không nên đưa mọi ý tưởng vào MVP. Ví dụ UniShare có thể mở rộng thanh toán online, quản trị tranh chấp hoặc báo cáo vi phạm, nhưng MVP tập trung trước vào:

- Đăng ký, đăng nhập và hồ sơ.
- Đăng bài cho thuê/cho mượn.
- Tìm kiếm và lọc bài đăng.
- Chat giữa hai bên.
- Gửi và xử lý yêu cầu thuê/mượn.
- Đánh giá uy tín.
- Thông báo.
- Ghi nhận đặt cọc cơ bản.

AI Agent giúp nhóm phân loại chức năng thành P0, P1, P2:

| Mức ưu tiên | Ý nghĩa                        | Ví dụ                           |
| ----------- | ------------------------------ | ------------------------------- |
| P0          | Bắt buộc để MVP chạy được      | Đăng nhập, đăng bài, tìm kiếm   |
| P1          | Quan trọng cho trải nghiệm tốt | Thông báo, ảnh đại diện, badge  |
| P2          | Có thể làm sau                 | Admin nâng cao, thanh toán thật |

### Bước 3. Viết yêu cầu chức năng

Yêu cầu chức năng mô tả người dùng có thể làm gì trong app. Đây là cầu nối giữa ý tưởng kinh doanh và phần mềm.

Trong UniShare, yêu cầu được viết theo mã `FR-*`, ví dụ:

- `FR-001`: Đăng ký tài khoản.
- `FR-005`: Tạo bài đăng cho thuê/cho mượn.
- `FR-010`: Tìm kiếm và lọc đồ dùng.
- `FR-014`: Gửi và nhận tin nhắn realtime.
- `FR-020`: Đánh giá và cập nhật điểm uy tín.

Khi làm việc với AI Agent, nhóm nên yêu cầu Agent viết rõ:

- Người dùng nào thực hiện chức năng.
- Điều kiện trước khi thực hiện.
- Luồng thành công.
- Các trường hợp lỗi.
- Quy tắc nghiệp vụ.

Prompt mẫu:

```text
Dựa trên ý tưởng UniShare, hãy viết danh sách use case cho MVP.
Mỗi use case cần có mã FR, tên chức năng, người dùng thực hiện,
luồng chính, lỗi có thể xảy ra và quy tắc nghiệp vụ quan trọng.
```

Kết quả của bước này là tài liệu [01-functional-requirements.md](../03-functional/01-functional-requirements.md).

### Bước 4. Thiết kế database ở mức khái niệm

Database là nơi lưu dữ liệu của app. Với UniShare, các nhóm dữ liệu chính gồm:

- Người dùng.
- Trường học và khu vực.
- Bài đăng đồ dùng.
- Ảnh bài đăng.
- Tag và loại đồ.
- Upvote và bình luận.
- Yêu cầu thuê/mượn.
- Đặt cọc.
- Chat và tin nhắn.
- Đánh giá.
- Thông báo.

Sinh viên kinh tế có thể hình dung database giống một hệ thống bảng Excel có quan hệ với nhau. Ví dụ:

- Một người dùng có thể tạo nhiều bài đăng.
- Một bài đăng có thể có nhiều ảnh.
- Một yêu cầu thuê/mượn thuộc về một bài đăng.
- Một giao dịch hoàn tất có thể tạo đánh giá.

AI Agent giúp chuyển các khái niệm nghiệp vụ này thành bảng dữ liệu, cột dữ liệu và quan hệ giữa bảng. Tuy nhiên, con người cần kiểm tra xem dữ liệu đó có đúng thực tế kinh doanh không.

Prompt mẫu:

```text
Hãy thiết kế database cho app UniShare ở mức MVP.
Cần có người dùng, bài đăng, ảnh, tag, chat, yêu cầu thuê/mượn,
đặt cọc, đánh giá và thông báo. Giải thích mỗi bảng lưu thông tin gì.
```

Kết quả của bước này là tài liệu [01-database-designer.md](../02-architecture/01-database-designer.md).

### Bước 5. Thiết kế API theo nhu cầu màn hình

API là cầu nối giữa app mobile và backend. App không trực tiếp lấy dữ liệu từ database, mà gửi yêu cầu qua API.

Ví dụ khi người dùng mở màn hình danh sách đồ:

1. Flutter app gọi API `GET /listings`.
2. Backend kiểm tra yêu cầu.
3. Backend lấy dữ liệu từ database.
4. Backend trả danh sách bài đăng về app.
5. App hiển thị danh sách cho người dùng.

Trong UniShare, API được thiết kế theo các nhóm:

- Authentication và Users.
- Listings và Listing Images.
- Tags, Categories, Schools, Areas.
- Upvotes và Comments.
- Conversations và Messages.
- Rental Requests và Deposits.
- Reviews.
- Notifications.
- SignalR Chat Hub.

Với sinh viên kinh tế, phần quan trọng không phải thuộc cú pháp API, mà là hiểu mỗi màn hình cần dữ liệu gì và thao tác gì.

Ví dụ:

| Màn hình       | Cần API để làm gì                                 |
| -------------- | ------------------------------------------------- |
| Login          | Gửi email/mật khẩu để đăng nhập                   |
| Home           | Lấy danh sách bài đăng                            |
| Listing Detail | Lấy chi tiết món đồ, upvote, mở chat, gửi yêu cầu |
| Chat Detail    | Lấy tin nhắn và gửi tin mới                       |
| Notifications  | Lấy danh sách thông báo và đánh dấu đã đọc        |

Kết quả của bước này là tài liệu [02-api-spec.md](../02-architecture/02-api-spec.md).

### Bước 6. Thiết kế UI và wireframe

UI là phần người dùng nhìn thấy và thao tác. Wireframe là bản phác thảo màn hình trước khi làm giao diện thật.

Trong UniShare, UI được chia thành các nhóm:

- Auth: Splash, Login, Register.
- Discovery: Home, Search, Listing Detail.
- Listing Management: Create Listing, Edit Listing, Manage Images.
- Interaction: Upvote, Comments, Public Profile.
- Chat: Conversation List, Chat Detail.
- Rental: Request Form, Request Detail, Deposit Status.
- Review: Review Form.
- Notification: Notification List.
- Profile: My Profile, Edit Profile.

AI Agent có thể tạo sitemap, danh sách màn hình và wireframe dạng text. Con người cần kiểm tra:

- Người dùng có đi từ màn hình này sang màn hình khác hợp lý không.
- Các thao tác chính có dễ tìm không.
- Khách chưa đăng nhập bị giới hạn ở đâu.
- Chủ bài đăng và người thuê/mượn thấy các nút khác nhau như thế nào.

Prompt mẫu:

```text
Hãy thiết kế sitemap và wireframe text cho app mobile UniShare.
App cần các màn hình: Home, Search, Listing Detail, Create Listing,
Chat, Rental Request, Notifications và Profile.
Mỗi màn hình cần ghi rõ mục tiêu, hành động chính và API liên quan.
```

Kết quả của bước này là tài liệu [01-ui-sitemap-and-wireframe.md](../04-ui/01-ui-sitemap-and-wireframe.md).

### Bước 7. Chia task theo phase

Sau khi có ý tưởng, yêu cầu, database, API và UI, nhóm cần chia việc thành các phase. Đây là bước rất quan trọng khi làm với AI Agent, vì Agent làm tốt hơn khi task rõ ràng và có tiêu chí hoàn thành.

UniShare chia task theo thứ tự:

| Phase   | Nội dung chính                    | Ý nghĩa                                                  |
| ------- | --------------------------------- | -------------------------------------------------------- |
| Phase 0 | Chuẩn bị repository và môi trường | Tạo nền móng dự án                                       |
| Phase 1 | Database, entity và migration     | Tạo cấu trúc dữ liệu                                     |
| Phase 2 | Backend API core                  | Làm các API chính                                        |
| Phase 3 | Backend testing                   | Kiểm tra backend                                         |
| Phase 4 | Flutter foundation                | Tạo nền giao diện mobile                                 |
| Phase 5 | Flutter UI screens                | Làm các màn hình chính                                   |
| Phase 6 | Flutter testing                   | Kiểm tra app mobile                                      |
| Phase 7 | Build APK                         | Tạo bản cài đặt                                          |
| Phase 8 | Sửa lỗi và cải thiện trải nghiệm  | Login persistence, avatar, notification badge, deep link |

Mỗi task trong task board nên có:

- ID task.
- Use case liên quan.
- Trạng thái.
- Ưu tiên.
- Dependency.
- Definition of Done.

Definition of Done nghĩa là điều kiện để xem task đã hoàn thành. Ví dụ: "Login thành công lưu token" hoặc "User chỉ xem notification của mình".

Kết quả của bước này là tài liệu [01-task-board.md](../05-tasks/01-task-board.md).

### Bước 8. Dùng AI Agent triển khai backend

Backend là nơi xử lý nghiệp vụ. Với UniShare, backend dùng **ASP.NET Core Web API (.NET 8)**, **Entity Framework Core**, **SQL Server**, **JWT** và **SignalR**.

AI Agent triển khai backend theo tài liệu đã có:

1. Đọc task board để biết task cần làm.
2. Đọc yêu cầu chức năng để hiểu nghiệp vụ.
3. Đọc database designer nếu task liên quan dữ liệu.
4. Đọc API spec nếu task liên quan endpoint.
5. Kiểm tra code hiện có để bám theo pattern.
6. Implement theo module nhỏ.
7. Viết hoặc cập nhật test.
8. Chạy build/test.
9. Ghi log nếu có quyết định hoặc lỗi quan trọng.

Ví dụ với chức năng tạo bài đăng:

- AI Agent đọc `FR-005`.
- Kiểm tra bảng `Listings`, `ListingImages`, `Tags`.
- Xem API `POST /listings`.
- Viết service/backend để tạo bài.
- Kiểm tra user đã đăng nhập chưa.
- Validate tiêu đề, mô tả, loại đồ, giá thuê.
- Chạy test để đảm bảo không sai quy tắc.

Điểm quan trọng: AI Agent không nên tự ý mở rộng chức năng ngoài MVP nếu chưa có yêu cầu.

### Bước 9. Dùng AI Agent triển khai Flutter app

Flutter app là phần người dùng sử dụng trên điện thoại. Với UniShare, Flutter cần gọi API, lưu token đăng nhập, hiển thị danh sách bài đăng, chat, gửi yêu cầu và nhận thông báo.

AI Agent triển khai Flutter theo thứ tự:

1. Tạo theme và component dùng chung.
2. Cấu hình routing/navigation theo sitemap.
3. Tạo API client để gọi backend.
4. Tạo model/DTO để parse dữ liệu trả về.
5. Làm từng màn hình theo wireframe.
6. Xử lý các state: loading, empty, error, unauthorized, forbidden, success.
7. Viết test cho form, màn hình và các trạng thái.

Ví dụ với màn hình Home:

- App gọi `GET /listings`.
- Nếu đang tải, hiển thị loading.
- Nếu không có bài, hiển thị empty state.
- Nếu API lỗi, hiển thị error.
- Nếu có dữ liệu, hiển thị danh sách bài đăng.
- Khi người dùng bấm một bài, mở Listing Detail.

Với sinh viên kinh tế, có thể hiểu Flutter là nơi biến logic sản phẩm thành trải nghiệm người dùng.

### Bước 10. Kiểm thử, sửa lỗi và test thiết bị thật

Kiểm thử giúp phát hiện app có hoạt động đúng như kỳ vọng không. UniShare có nhiều loại kiểm thử:

- Backend unit test: kiểm tra logic nhỏ như đăng nhập, token, trạng thái giao dịch.
- Backend integration test: kiểm tra API hoạt động đúng.
- Flutter unit/widget test: kiểm tra màn hình, form, trạng thái loading/error.
- Manual test: tự thao tác app như người dùng thật.
- Real device test: cài lên điện thoại thật để phát hiện lỗi môi trường.

Trong log của UniShare, test thiết bị thật đã phát hiện nhiều lỗi thực tế như:

- Đăng nhập thành công nhưng app báo thất bại.
- Dữ liệu API có dạng khác Flutter mong đợi.
- Filter bottom sheet bị tràn giao diện.
- Ảnh không hiển thị do URL tương đối.
- Upload ảnh trên web/mobile cần xử lý khác nhau.

Đây là bài học quan trọng: **AI Agent có thể viết nhanh, nhưng app vẫn cần được chạy thật, kiểm tra thật và sửa lỗi dựa trên tình huống thật**.

### Bước 11. Build APK và ghi lại bài học

Khi app đủ ổn, nhóm build APK để cài thử trên thiết bị Android. Với UniShare, phase build gồm:

- Cấu hình app id, app name, icon và splash.
- Cấu hình permission như internet, camera/gallery.
- Cấu hình signing key.
- Build debug APK.
- Build release APK.
- Smoke test bản APK trên thiết bị thật.
- Ghi release notes và known issues.

Sau mỗi giai đoạn, nhóm nên ghi session log:

- Ngày làm.
- Người thực hiện.
- Task liên quan.
- Vấn đề gặp phải.
- Nguyên nhân.
- Cách sửa.
- Bài học.

Log giúp nhóm giải trình quá trình làm dự án và tránh lặp lại lỗi cũ.

## 7. Prompt mẫu khi làm việc với AI Agent

### Prompt lập kế hoạch

```text
Hãy đọc tài liệu trong docs/ và lập kế hoạch triển khai chức năng tạo bài đăng.
Kế hoạch cần nêu file/tài liệu liên quan, dữ liệu cần dùng, API cần gọi,
edge case, test cần viết và definition of done.
```

### Prompt viết yêu cầu chức năng

```text
Hãy viết use case cho chức năng gửi yêu cầu thuê/mượn trong UniShare.
Người gửi là sinh viên muốn thuê/mượn đồ, người nhận là chủ bài đăng.
Cần có luồng thành công, trường hợp lỗi và quy tắc trạng thái.
```

### Prompt thiết kế màn hình

```text
Hãy thiết kế wireframe text cho màn hình Listing Detail.
Màn hình cần hiển thị ảnh, tên đồ, giá thuê, tiền cọc, chủ bài,
tag, khu vực, nút chat, nút gửi yêu cầu và phần bình luận.
```

### Prompt triển khai có kiểm soát

```text
Hãy triển khai task FE-LIST-003 theo tài liệu trong docs/.
Không mở rộng scope ngoài task. Sau khi làm xong, chạy test phù hợp
và báo cáo file đã sửa, test đã chạy, rủi ro còn lại.
```

### Prompt sửa lỗi

```text
App báo lỗi khi mở Listing Detail: dữ liệu tag parse sai kiểu.
Hãy đọc API spec, DTO Flutter và log lỗi, sau đó đề xuất nguyên nhân,
cách sửa tối thiểu và test cần bổ sung.
```

### Prompt viết log

```text
Hãy viết session log cho lỗi đăng nhập thành công nhưng app không chuyển vào Home.
Log cần có triệu chứng, nguyên nhân, cách sửa, file liên quan và bài học.
```

## 8. Lỗi thường gặp khi làm app với AI Agent

| Lỗi                               | Hậu quả                                    | Cách tránh                                                  |
| --------------------------------- | ------------------------------------------ | ----------------------------------------------------------- |
| Yêu cầu quá mơ hồ                 | AI Agent tự đoán, dễ làm lệch mục tiêu     | Viết rõ người dùng, mục tiêu, phạm vi và definition of done |
| Không có tài liệu nền             | Code thiếu nhất quán                       | Bắt đầu từ idea, requirements, database, API, UI            |
| Làm quá nhiều chức năng cùng lúc  | Khó kiểm soát lỗi                          | Chia phase và task nhỏ                                      |
| Tin hoàn toàn vào code AI tạo     | Có lỗi nghiệp vụ hoặc lỗi môi trường       | Luôn review, chạy test và test thủ công                     |
| Không ghi log                     | Khó giải trình quá trình làm dự án         | Ghi session log cho quyết định và lỗi quan trọng            |
| Không kiểm tra trên thiết bị thật | App chạy ở máy dev nhưng lỗi khi dùng thật | Có bước real device test trước khi kết luận                 |
| Mở rộng ngoài MVP                 | Trễ tiến độ, app thiếu ổn định             | Ưu tiên P0 trước, P1/P2 làm sau                             |

## 9. Bài học rút ra từ UniShare

### Tài liệu là nền móng để AI Agent làm đúng

UniShare có tài liệu theo nhiều lớp: ý tưởng, yêu cầu chức năng, database, API, UI, task board và log. Nhờ vậy AI Agent có thể đọc ngữ cảnh trước khi làm, thay vì viết theo phỏng đoán.

### MVP giúp dự án không bị quá tải

Một app chia sẻ đồ dùng có thể có rất nhiều chức năng, nhưng UniShare tập trung vào luồng cốt lõi: đăng đồ, tìm đồ, chat, gửi yêu cầu, hoàn tất và đánh giá. Đây là cách giữ dự án vừa sức.

### AI Agent mạnh nhất khi task rõ ràng

Task có ID, dependency và definition of done giúp Agent biết cần làm gì và khi nào được xem là xong. Đây là điểm sinh viên nên học khi quản lý dự án công nghệ.

### Kiểm thử thực tế rất quan trọng

Nhiều lỗi chỉ xuất hiện khi chạy app thật: đăng nhập, upload ảnh, URL ảnh, layout tràn, môi trường điện thoại. Vì vậy, hoàn thành code chưa đồng nghĩa hoàn thành sản phẩm.

### Con người vẫn chịu trách nhiệm cuối cùng

AI Agent có thể gợi ý và triển khai nhanh, nhưng nhóm làm dự án phải kiểm tra xem sản phẩm có đúng mục tiêu môn học, đúng nhu cầu người dùng và đúng phạm vi đã cam kết không.

## 10. Checklist áp dụng cho nhóm sinh viên

Trước khi dùng AI Agent để làm app, nhóm có thể đi theo checklist sau:

### Giai đoạn ý tưởng

- [ ] Xác định vấn đề thực tế.
- [ ] Xác định người dùng mục tiêu.
- [ ] Mô tả giá trị app mang lại.
- [ ] Liệt kê chức năng MVP.
- [ ] Chọn chức năng nào làm sau MVP.

### Giai đoạn phân tích

- [ ] Viết yêu cầu chức năng theo use case.
- [ ] Xác định vai trò người dùng.
- [ ] Viết quy tắc nghiệp vụ quan trọng.
- [ ] Thiết kế dữ liệu chính cần lưu.
- [ ] Thiết kế màn hình và luồng điều hướng.

### Giai đoạn kỹ thuật

- [ ] Chọn công nghệ frontend, backend, database.
- [ ] Thiết kế API theo nhu cầu màn hình.
- [ ] Chia task theo phase.
- [ ] Ghi rõ dependency và definition of done.
- [ ] Yêu cầu AI Agent đọc tài liệu trước khi implement.

### Giai đoạn triển khai

- [ ] Làm backend trước các API cốt lõi.
- [ ] Làm frontend theo sitemap/wireframe.
- [ ] Xử lý loading, empty, error và unauthorized state.
- [ ] Viết test phù hợp.
- [ ] Chạy build/test sau mỗi nhóm chức năng.

### Giai đoạn hoàn thiện

- [ ] Test luồng chính end-to-end.
- [ ] Test trên thiết bị thật.
- [ ] Ghi lại lỗi và cách sửa.
- [ ] Build APK hoặc bản demo.
- [ ] Viết bài học và giới hạn còn lại của sản phẩm.

## 11. Kết luận

AI Agent là công cụ rất hữu ích để sinh viên xây dựng ứng dụng, đặc biệt khi dự án có nhiều phần như backend, database, API, giao diện mobile và kiểm thử. Tuy nhiên, để AI Agent làm việc hiệu quả, nhóm cần chuẩn bị tài liệu rõ ràng, chia task hợp lý và luôn kiểm tra kết quả.

Với UniShare, quy trình phát triển có thể tóm tắt như sau:

```text
Vấn đề thực tế
-> Ý tưởng sản phẩm
-> MVP
-> Yêu cầu chức năng
-> Database
-> API
-> UI/Wireframe
-> Task board
-> Backend
-> Flutter app
-> Test và sửa lỗi
-> Build APK
-> Ghi log và rút bài học
```

Đây cũng là tư duy quan trọng cho sinh viên kinh tế khi tham gia các dự án công nghệ: không nhất thiết phải bắt đầu từ code, mà nên bắt đầu từ vấn đề, người dùng, giá trị và quy trình triển khai có kiểm soát.
