using FluentValidation;
using UniShare.API.Models.DTOs.Listings;

namespace UniShare.API.Validators.Listings;

public class CreateListingRequestValidator : AbstractValidator<CreateListingRequest>
{
    public CreateListingRequestValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Title is required")
            .MinimumLength(5).WithMessage("Title must be at least 5 characters")
            .MaximumLength(200).WithMessage("Title must not exceed 200 characters");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Description is required")
            .MinimumLength(20).WithMessage("Description must be at least 20 characters")
            .MaximumLength(2000).WithMessage("Description must not exceed 2000 characters");

        RuleFor(x => x.CategoryId)
            .NotEmpty().WithMessage("Category is required");

        RuleFor(x => x.ListingType)
            .NotEmpty().WithMessage("Listing type is required")
            .Must(lt => lt is "Rent" or "Borrow")
            .WithMessage("Listing type must be 'Rent' or 'Borrow'");

        // PricePerDay: required when Rent, must be 0 when Borrow
        RuleFor(x => x.PricePerDay)
            .GreaterThanOrEqualTo(0).WithMessage("Price per day must not be negative")
            .Must((request, price) =>
                request.ListingType != "Rent" || price > 0)
            .WithMessage("Price per day is required for Rent listings")
            .Must((request, price) =>
                request.ListingType != "Borrow" || price == 0)
            .WithMessage("Price per day must be 0 for Borrow listings");

        RuleFor(x => x.DepositAmount)
            .GreaterThanOrEqualTo(0).WithMessage("Deposit amount must not be negative")
            .When(x => x.DepositAmount.HasValue);

        RuleFor(x => x.ConditionNote)
            .MaximumLength(500).WithMessage("Condition note must not exceed 500 characters")
            .When(x => !string.IsNullOrEmpty(x.ConditionNote));

        RuleFor(x => x.TagNames)
            .Must(tags => tags.Count <= 10)
            .WithMessage("Maximum 10 tags allowed");

        RuleForEach(x => x.TagNames)
            .MinimumLength(2).WithMessage("Each tag must be at least 2 characters")
            .MaximumLength(50).WithMessage("Each tag must not exceed 50 characters");
    }
}
