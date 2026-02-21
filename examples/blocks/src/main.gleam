//// QA block compositions for weft_lustre_ui.
////
//// Validates that the component library works end-to-end by composing
//// shadcn-style "blocks" using only weft typed primitives with zero
//// escape hatches.

import lustre
import lustre/element
import weft
import weft_lustre
import weft_lustre_ui/button
import weft_lustre_ui/card
import weft_lustre_ui/field
import weft_lustre_ui/forms
import weft_lustre_ui/headless/separator as headless_separator
import weft_lustre_ui/input
import weft_lustre_ui/label
import weft_lustre_ui/link
import weft_lustre_ui/separator
import weft_lustre_ui/theme

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Application model holding state for all block compositions.
type Model {
  Model(
    login_email: String,
    login_password: String,
    signup_name: String,
    signup_email: String,
    signup_password: String,
    signup_confirm_password: String,
  )
}

// ---------------------------------------------------------------------------
// Messages
// ---------------------------------------------------------------------------

/// Messages for all block compositions.
type Msg {
  LoginSetEmail(value: String)
  LoginSetPassword(value: String)
  LoginSubmit
  LoginGoogle
  SignupSetName(value: String)
  SignupSetEmail(value: String)
  SignupSetPassword(value: String)
  SignupSetConfirmPassword(value: String)
  SignupSubmit
  SignupGoogle
}

// ---------------------------------------------------------------------------
// Init / Update
// ---------------------------------------------------------------------------

fn init(_flags) -> Model {
  Model(
    login_email: "",
    login_password: "",
    signup_name: "",
    signup_email: "",
    signup_password: "",
    signup_confirm_password: "",
  )
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    LoginSetEmail(value:) -> Model(..model, login_email: value)
    LoginSetPassword(value:) -> Model(..model, login_password: value)
    LoginSubmit -> model
    LoginGoogle -> model
    SignupSetName(value:) -> Model(..model, signup_name: value)
    SignupSetEmail(value:) -> Model(..model, signup_email: value)
    SignupSetPassword(value:) -> Model(..model, signup_password: value)
    SignupSetConfirmPassword(value:) ->
      Model(..model, signup_confirm_password: value)
    SignupSubmit -> model
    SignupGoogle -> model
  }
}

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

fn view(model: Model) -> element.Element(Msg) {
  let t = theme.theme_default()

  weft_lustre.layout(
    attrs: [],
    child: weft_lustre.column(
      attrs: [
        weft_lustre.styles([
          weft.spacing(pixels: 64),
          weft.align_items(value: weft.align_items_center()),
          weft.width(length: weft.fill()),
          weft.padding(pixels: 24),
        ]),
      ],
      children: [
        page_layout(theme: t, child: login_01_view(theme: t, model: model)),
        page_layout(theme: t, child: signup_01_view(theme: t, model: model)),
      ],
    ),
  )
}

/// Center a block in a full-height container with max-width constraint.
fn page_layout(
  theme _theme: theme.Theme,
  child child: weft_lustre.Element(Msg),
) -> weft_lustre.Element(Msg) {
  weft_lustre.column(
    attrs: [
      weft_lustre.styles([
        weft.display(value: weft.display_flex()),
        weft.align_items(value: weft.align_items_center()),
        weft.justify_content(value: weft.justify_center()),
        weft.width(length: weft.fill()),
        weft.height(length: weft.minimum(
          base: weft.fill(),
          min: weft.vh(vh: 100.0),
        )),
        weft.padding(pixels: 24),
      ]),
    ],
    children: [
      weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.width(length: weft.maximum(
              base: weft.fill(),
              max: weft.px(pixels: 384),
            )),
          ]),
        ],
        child: child,
      ),
    ],
  )
}

// ---------------------------------------------------------------------------
// Login-01: Simple Login Card
// ---------------------------------------------------------------------------

fn login_01_view(
  theme t: theme.Theme,
  model model: Model,
) -> weft_lustre.Element(Msg) {
  card.card(theme: t, attrs: [], children: [
    card.card_header(theme: t, attrs: [], children: [
      card.card_title(theme: t, attrs: [], children: [
        weft_lustre.text(content: "Login to your account"),
      ]),
      card.card_description(theme: t, attrs: [], children: [
        weft_lustre.text(
          content: "Enter your email below to login to your account",
        ),
      ]),
    ]),
    card.card_content(theme: t, attrs: [], children: [
      weft_lustre.column(
        attrs: [
          weft_lustre.styles([
            weft.spacing(pixels: 16),
            weft.align_items(value: weft.align_items_stretch()),
          ]),
        ],
        children: [
          // Email field
          forms.field_text_input(
            theme: t,
            field_config: field.field_config(id: "login-email")
              |> field.field_label_text(text: "Email")
              |> field.field_required(),
            input_config: input.text_input_config(
              value: model.login_email,
              on_input: LoginSetEmail,
            )
              |> input.text_input_type(input_type: input.input_type_email())
              |> input.text_input_placeholder(value: "m@example.com"),
          ),
          // Password field with label row (label + forgot password link)
          login_password_field(theme: t, model: model),
          // Action buttons and footer text
          weft_lustre.column(
            attrs: [
              weft_lustre.styles([
                weft.spacing(pixels: 8),
                weft.align_items(value: weft.align_items_stretch()),
              ]),
            ],
            children: [
              button.button(
                theme: t,
                config: button.button_config(on_press: LoginSubmit)
                  |> button.button_attrs(attrs: [
                    weft_lustre.styles([
                      weft.width(
                        length: weft.fixed(length: weft.pct(pct: 100.0)),
                      ),
                    ]),
                  ]),
                label: weft_lustre.text(content: "Login"),
              ),
              button.button(
                theme: t,
                config: button.button_config(on_press: LoginGoogle)
                  |> button.button_variant(variant: button.secondary())
                  |> button.button_attrs(attrs: [
                    weft_lustre.styles([
                      weft.width(
                        length: weft.fixed(length: weft.pct(pct: 100.0)),
                      ),
                    ]),
                  ]),
                label: weft_lustre.text(content: "Login with Google"),
              ),
              // "Don't have an account? Sign up"
              centered_footer_text(
                theme: t,
                prefix: "Don't have an account? ",
                link_text: "Sign up",
                href: "#signup",
              ),
            ],
          ),
        ],
      ),
    ]),
  ])
}

/// Password field with a row header containing the label and a "Forgot your
/// password?" link aligned to opposite ends.
fn login_password_field(
  theme t: theme.Theme,
  model model: Model,
) -> weft_lustre.Element(Msg) {
  field.field(
    theme: t,
    config: field.field_config(id: "login-password")
      |> field.field_label(
        label: weft_lustre.row(
          attrs: [
            weft_lustre.styles([
              weft.justify_content(value: weft.justify_space_between()),
              weft.align_items(value: weft.align_items_center()),
              weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
            ]),
          ],
          children: [
            label.label(
              theme: t,
              config: label.label_config()
                |> label.label_for(html_for: "login-password"),
              child: weft_lustre.text(content: "Password"),
            ),
            link.link(
              theme: t,
              config: link.link_config(href: "#forgot")
                |> link.link_attrs(attrs: [
                  weft_lustre.styles([
                    weft.font_size(size: weft.rem(rem: 0.8125)),
                    weft.font_weight(weight: weft.font_weight_value(weight: 400)),
                  ]),
                ]),
              label: weft_lustre.text(content: "Forgot your password?"),
            ),
          ],
        ),
      )
      |> field.field_required(),
    control: fn(attrs) {
      input.text_input(
        theme: t,
        config: input.text_input_config(
          value: model.login_password,
          on_input: LoginSetPassword,
        )
          |> input.text_input_type(input_type: input.input_type_password())
          |> input.text_input_attrs(attrs: attrs),
      )
    },
  )
}

// ---------------------------------------------------------------------------
// Signup-01: Simple Signup Card
// ---------------------------------------------------------------------------

fn signup_01_view(
  theme t: theme.Theme,
  model model: Model,
) -> weft_lustre.Element(Msg) {
  card.card(theme: t, attrs: [], children: [
    card.card_header(theme: t, attrs: [], children: [
      card.card_title(theme: t, attrs: [], children: [
        weft_lustre.text(content: "Create an account"),
      ]),
      card.card_description(theme: t, attrs: [], children: [
        weft_lustre.text(content: "Enter your information to create an account"),
      ]),
    ]),
    card.card_content(theme: t, attrs: [], children: [
      weft_lustre.column(
        attrs: [
          weft_lustre.styles([
            weft.spacing(pixels: 16),
            weft.align_items(value: weft.align_items_stretch()),
          ]),
        ],
        children: [
          // Name field
          forms.field_text_input(
            theme: t,
            field_config: field.field_config(id: "signup-name")
              |> field.field_label_text(text: "Name")
              |> field.field_required(),
            input_config: input.text_input_config(
              value: model.signup_name,
              on_input: SignupSetName,
            )
              |> input.text_input_placeholder(value: "John Doe"),
          ),
          // Email field with help text
          forms.field_text_input(
            theme: t,
            field_config: field.field_config(id: "signup-email")
              |> field.field_label_text(text: "Email")
              |> field.field_help_text(
                text: "We'll use this to contact you about your account",
              )
              |> field.field_required(),
            input_config: input.text_input_config(
              value: model.signup_email,
              on_input: SignupSetEmail,
            )
              |> input.text_input_type(input_type: input.input_type_email())
              |> input.text_input_placeholder(value: "m@example.com"),
          ),
          // Password field with help text
          forms.field_text_input(
            theme: t,
            field_config: field.field_config(id: "signup-password")
              |> field.field_label_text(text: "Password")
              |> field.field_help_text(text: "Must be at least 8 characters")
              |> field.field_required(),
            input_config: input.text_input_config(
              value: model.signup_password,
              on_input: SignupSetPassword,
            )
              |> input.text_input_type(input_type: input.input_type_password())
              |> input.text_input_placeholder(value: "Enter your password"),
          ),
          // Confirm password field with help text
          forms.field_text_input(
            theme: t,
            field_config: field.field_config(id: "signup-confirm-password")
              |> field.field_label_text(text: "Confirm Password")
              |> field.field_help_text(text: "Please confirm your password")
              |> field.field_required(),
            input_config: input.text_input_config(
              value: model.signup_confirm_password,
              on_input: SignupSetConfirmPassword,
            )
              |> input.text_input_type(input_type: input.input_type_password())
              |> input.text_input_placeholder(value: "Confirm your password"),
          ),
          // Separator
          separator.separator(
            theme: t,
            config: headless_separator.separator_config(),
          ),
          // Action buttons and footer text
          weft_lustre.column(
            attrs: [
              weft_lustre.styles([
                weft.spacing(pixels: 8),
                weft.align_items(value: weft.align_items_stretch()),
              ]),
            ],
            children: [
              button.button(
                theme: t,
                config: button.button_config(on_press: SignupSubmit)
                  |> button.button_attrs(attrs: [
                    weft_lustre.styles([
                      weft.width(
                        length: weft.fixed(length: weft.pct(pct: 100.0)),
                      ),
                    ]),
                  ]),
                label: weft_lustre.text(content: "Create Account"),
              ),
              button.button(
                theme: t,
                config: button.button_config(on_press: SignupGoogle)
                  |> button.button_variant(variant: button.secondary())
                  |> button.button_attrs(attrs: [
                    weft_lustre.styles([
                      weft.width(
                        length: weft.fixed(length: weft.pct(pct: 100.0)),
                      ),
                    ]),
                  ]),
                label: weft_lustre.text(content: "Sign up with Google"),
              ),
              // "Already have an account? Sign in"
              centered_footer_text(
                theme: t,
                prefix: "Already have an account? ",
                link_text: "Sign in",
                href: "#login",
              ),
            ],
          ),
        ],
      ),
    ]),
  ])
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/// Render a centered muted text line with an embedded link.
fn centered_footer_text(
  theme t: theme.Theme,
  prefix prefix: String,
  link_text link_text: String,
  href href: String,
) -> weft_lustre.Element(Msg) {
  weft_lustre.row(
    attrs: [
      weft_lustre.styles([
        weft.justify_content(value: weft.justify_center()),
        weft.align_items(value: weft.align_items_center()),
        weft.spacing(pixels: 4),
        weft.font_size(size: weft.rem(rem: 0.875)),
        weft.font_family(families: theme.font_families(t)),
      ]),
    ],
    children: [
      weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.text_color(color: theme.muted_text(t)),
          ]),
        ],
        child: weft_lustre.text(content: prefix),
      ),
      link.link(
        theme: t,
        config: link.link_config(href: href),
        label: weft_lustre.text(content: link_text),
      ),
    ],
  )
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

/// Application entry point.
pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}
