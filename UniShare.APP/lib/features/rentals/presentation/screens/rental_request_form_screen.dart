import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../models/create_rental_request_request.dart';
import '../providers/rentals_provider.dart' show rentalsRepositoryProvider;

class RentalRequestFormScreen extends ConsumerStatefulWidget {
  final String listingId;
  final String listingTitle;
  final double listingPricePerDay;
  final double listingDepositAmount;
  final String listingType;

  const RentalRequestFormScreen({
    super.key,
    required this.listingId,
    required this.listingTitle,
    required this.listingPricePerDay,
    required this.listingDepositAmount,
    required this.listingType,
  });

  @override
  ConsumerState<RentalRequestFormScreen> createState() =>
      _RentalRequestFormScreenState();
}

enum _FormStatus { editing, submitting }

class _RentalRequestFormScreenState
    extends ConsumerState<RentalRequestFormScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _message;
  _FormStatus _status = _FormStatus.editing;
  String? _errorMessage;

  bool get _isBorrow => widget.listingType.toLowerCase() == 'borrow';

  bool get _isValid =>
      _startDate != null &&
      _endDate != null &&
      !_endDate!.isBefore(_startDate!);

  int get _numberOfDays {
    if (_startDate == null || _endDate == null) return 0;
    final days = _endDate!.difference(_startDate!).inDays + 1;
    return days < 1 ? 0 : days;
  }

  int get _calculatedTotalPrice {
    if (_isBorrow) return 0;
    return (_numberOfDays * widget.listingPricePerDay).round();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = isStart
        ? (_startDate ?? today)
        : (_endDate ?? today);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(today) ? today : initialDate,
      firstDate: today,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: isStart ? 'Chọn ngày bắt đầu' : 'Chọn ngày kết thúc',
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
        _errorMessage = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_isValid) {
      setState(() => _errorMessage = 'Vui lòng chọn ngày bắt đầu và kết thúc');
      return;
    }

    setState(() {
      _status = _FormStatus.submitting;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(rentalsRepositoryProvider);
      await repo.createRentalRequest(
        widget.listingId,
        CreateRentalRequestRequest(
          startDate: _startDate!,
          endDate: _endDate!,
          message: _message,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi yêu cầu thành công!')),
        );
        context.pop(true);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _status = _FormStatus.editing;
          _errorMessage = _mapError(e.toString());
        });
      }
    }
  }

  String _mapError(String error) {
    if (error.contains('409')) {
      return 'Bạn đã có yêu cầu đang hoạt động cho bài đăng này';
    }
    if (error.contains('403')) {
      return 'Bạn không thể gửi yêu cầu cho bài đăng của chính mình';
    }
    return 'Không thể gửi yêu cầu. Vui lòng thử lại sau.';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(_isBorrow ? 'Gửi yêu cầu mượn' : 'Gửi yêu cầu thuê'),
      ),
      body: _status == _FormStatus.submitting
          ? Stack(
              children: [
                _buildForm(),
                Container(
                  color: Colors.white.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  ),
                ),
              ],
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Listing info card
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.listingTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _isBorrow
                                ? 'Miễn phí'
                                : '${widget.listingPricePerDay.toStringAsFixed(0)}đ/ngày',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (!_isBorrow && widget.listingDepositAmount > 0) ...[
                            const SizedBox(width: 16),
                            Container(
                              width: 1, height: 16,
                              color: AppColors.neutral200,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Cọc: ${widget.listingDepositAmount.toStringAsFixed(0)}đ',
                              style: const TextStyle(
                                color: AppColors.neutral700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text('Thời gian', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              // Start date
              InkWell(
                onTap: () => _pickDate(true),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neutral200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: AppColors.neutral500),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _startDate != null
                              ? _formatDate(_startDate!)
                              : 'Ngày bắt đầu',
                          style: TextStyle(
                            color: _startDate != null
                                ? AppColors.neutral900
                                : AppColors.neutral500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // End date
              InkWell(
                onTap: () => _pickDate(false),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neutral200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: AppColors.neutral500),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _endDate != null
                              ? _formatDate(_endDate!)
                              : 'Ngày kết thúc',
                          style: TextStyle(
                            color: _endDate != null
                                ? AppColors.neutral900
                                : AppColors.neutral500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Inline error
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 18, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: AppColors.danger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Price calculation
              if (_startDate != null && _endDate != null) ...[
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  color: AppColors.neutral100,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chi tiết giá',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _buildPriceRow('Số ngày', '$_numberOfDays ngày'),
                        const SizedBox(height: 6),
                        _buildPriceRow(
                          'Đơn giá',
                          _isBorrow
                              ? 'Miễn phí'
                              : '${widget.listingPricePerDay.toStringAsFixed(0)}đ/ngày',
                        ),
                        const Divider(height: 24),
                        _buildPriceRow(
                          'Tổng tiền',
                          _isBorrow
                              ? 'Miễn phí'
                              : '${_formatCurrency(_calculatedTotalPrice.toDouble())}đ',
                          bold: true,
                        ),
                        if (widget.listingDepositAmount > 0) ...[
                          const SizedBox(height: 6),
                          _buildPriceRow(
                            'Tiền cọc',
                            '${_formatCurrency(widget.listingDepositAmount)}đ',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Message input
              Text('Lời nhắn (không bắt buộc)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 4,
                minLines: 3,
                onChanged: (v) => _message = v.isEmpty ? null : v,
                decoration: const InputDecoration(
                  hintText: 'Gửi lời nhắn đến chủ bài đăng...',
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),

        // Submit button
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Gửi yêu cầu',
                onPressed:
                    _isValid && _status != _FormStatus.submitting
                        ? _submit
                        : null,
                isDisabled: !_isValid || _status == _FormStatus.submitting,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          color: AppColors.neutral700, fontSize: 14,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        )),
        Text(value, style: TextStyle(
          color: bold ? AppColors.green : AppColors.neutral900,
          fontSize: 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        )),
      ],
    );
  }
}
