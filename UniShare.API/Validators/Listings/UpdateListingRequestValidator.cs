using FluentValidation;
using UniShare.API.Models.DTOs.Listings;

namespace UniShare.API.Validators.Listings;

public class UpdateListingRequestValidator : AbstractValidator<UpdateListingRequest>
{
    public UpdateListingRequestValidator()
    {
        RuleFor(x => x.Title)
            .MinimumLength(5).WithMessage("Title must be at least 5 characters")
            .MaximumLength(200).WithMessage("Title must not exceed 200 characters")
            .When(x => !string.IsNullOrEmpty(x.Title));

        RuleFor(x => x.Description)
            .MinimumLength(20).WithMessage("Description must be at least 20 characters")
            .MaximumLength(2000).WithMessage("Description must not exceed 2000 characters")
            .When(x => !string.IsNullOrEmpty(x.Description));

        RuleFor(x => x.PricePerDay)
            .GreaterThanOrEqualTo(0).WithMessage("Price per day must not be negative")
            .When(x => x.PricePerDay.HasValue);

        RuleFor(x => x.DepositAmount)
            .GreaterThanOrEqualTo(0).WithMessage("Deposit amount must not be negative")
            .When(x => x.DepositAmount.HasValue);

        RuleFor(x => x.ConditionNote)
            .MaximumLength(500).WithMessage("Condition note must not exceed 500 characters")
            .When(x => !string.IsNullOrEmpty(x.ConditionNote));

        RuleFor(x => x.TagNames)
            .Must(tags => tags == null || tags.Count <= 10)
            .WithMessage("Maximum 10 tags allowed")
            .When(x => x.TagNames != null);

        RuleForEach(x => x.TagNames)
            .MinimumLength(2).WithMessage("Each tag must be at least 2 characters")
            .MaximumLength(50).WithMessage("Each tag must not exceed 50 characters")
            .When(x => x.TagNames != null);
    }
}
