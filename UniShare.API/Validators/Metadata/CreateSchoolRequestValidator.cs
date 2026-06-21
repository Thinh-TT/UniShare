using FluentValidation;
using UniShare.API.Models.DTOs.Metadata;

namespace UniShare.API.Validators.Metadata;

public class CreateSchoolRequestValidator : AbstractValidator<CreateSchoolRequest>
{
    public CreateSchoolRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("School name is required")
            .MaximumLength(150).WithMessage("School name must not exceed 150 characters");

        RuleFor(x => x.ShortName)
            .NotEmpty().WithMessage("Short name is required")
            .MaximumLength(50).WithMessage("Short name must not exceed 50 characters");

        RuleFor(x => x.City)
            .NotEmpty().WithMessage("City is required")
            .MaximumLength(100).WithMessage("City must not exceed 100 characters");
    }
}
