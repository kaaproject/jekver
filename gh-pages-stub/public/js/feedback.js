/*
 * Copyright 2014-2017 CyberVision, Inc.
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
FEEDBACK_SUBMIT_BUTTON_SELECTOR="#feedbackSubmit";
FEEDBACK_RESULT_SELECTOR="#feedbackResult";
FEEDBACK_INPUT_FORM_SELECTOR='#feedbackAsk';
FEEDBACK_ANIMATION_TIME=500;
COOKIES_SELECTOR_PREFIX='jekver-feedback-';
ACTIVE_FEEDBACK_TYPE_SELECTOR='#feedbackAsk .btn.btn-primary.active > input';
FEEDBACK_EMAIL_SELECTOR='#feedbackEmail1';
FEEDBACK_TEXT_SELECTOR='#feedbackTextarea';
FEEDBACK_BTN_SELECTOR='#btnShowfeedbackForm';
SCROLL_ELEMENT_SELECTOR="div#main"

$(document).ready(function(){

  function getCookieSelector() {
    return COOKIES_SELECTOR_PREFIX + UTILS.getPathname();
  }

  /* Enable popovers with html */
  $("[data-toggle=popover]").popover({html : true});

  /* Check the cookies . If there is no feedback for this page */
  if (!Cookies.get(getCookieSelector())) {
    $(SCROLL_ELEMENT_SELECTOR).scroll(function() {
      /* Open feedbakc form when user scrolls to the bottom */
      if($(SCROLL_ELEMENT_SELECTOR).scrollTop() >= $(SCROLL_ELEMENT_SELECTOR)[0].scrollHeight -  $(window).height()) {
        $(FEEDBACK_BTN_SELECTOR).trigger('click');
        /* unregister event */
        $(this).unbind("scroll");
      }
    });
  }

  /* Setup popover close button functionality */
  $(document).on("click", ".popover .feedback-close" , function(){
      $(this).parents(".popover").prev().trigger('click');
  });

  $(document).on("click", FEEDBACK_SUBMIT_BUTTON_SELECTOR , function(){
    /* Check cache and show feedback field if necessary */
    var TITLE=document.title;
    var VERSION = UTILS.getVersionFromURL();
    var FEEDBACK_TYPE = $(ACTIVE_FEEDBACK_TYPE_SELECTOR)[0].id;
    var FEEDBACK_EMAIL = $(FEEDBACK_EMAIL_SELECTOR)[0].value;
    var FEEDBACK_TEXT = $(FEEDBACK_TEXT_SELECTOR)[0].value;

    Analytic.getInstance().sendFeedback(FEEDBACK_TYPE,VERSION,TITLE,FEEDBACK_EMAIL,FEEDBACK_TEXT);
    Cookies.set(getCookieSelector(), true,  { path: UTILS.getPathname() });
    $(FEEDBACK_INPUT_FORM_SELECTOR).hide(FEEDBACK_ANIMATION_TIME);
    $(FEEDBACK_RESULT_SELECTOR).show(FEEDBACK_ANIMATION_TIME);
  })
})
