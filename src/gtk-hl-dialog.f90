! Copyright (C) 2011
! Free Software Foundation, Inc.

! This file is part of the gtk-fortran GTK+ Fortran Interface library.

! This is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 3, or (at your option)
! any later version.

! This software is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.

! Under Section 7 of GPL version 3, you are granted additional
! permissions described in the GCC Runtime Library Exception, version
! 3.1, as published by the Free Software Foundation.

! You should have received a copy of the GNU General Public License along with
! this program; see the files COPYING3 and COPYING.RUNTIME respectively.
! If not, see <http://www.gnu.org/licenses/>.
!
! Contributed by James Tappin
! Last modification: 11-21-2011

! --------------------------------------------------------
! gtk-hl-dialog.f90
! Generated: Sun Jul 29 09:00:26 2012 GMT
! Please do not edit this file directly,
! Edit gtk-hl-dialog-tmpl.f90, and use ./mk_gtk_hl.pl to regenerate.
! --------------------------------------------------------


module gtk_hl_dialog
  !*
  ! Dialogue
  ! The message dialogue provided is here because, the built-in message
  ! dialogue GtkMessageDialog cannot be created without calling variadic
  ! functions which are not compatible with Fortran, therefore this is
  ! based around the plain GtkDialog family.
  !/

  use gtk_sup
  use iso_c_binding
  ! autogenerated use's
  use gtk, only: gtk_box_pack_start, gtk_dialog_add_button,&
       & gtk_dialog_get_content_area, gtk_dialog_new, gtk_dialog_run,&
       & gtk_hbox_new, gtk_image_new, gtk_image_new_from_stock,&
       & gtk_label_new, gtk_label_set_markup, gtk_vbox_new,&
       & gtk_widget_destroy, gtk_widget_show, gtk_widget_show_all,&
       & gtk_window_set_destroy_with_parent, gtk_window_set_modal,&
       & gtk_window_set_title, gtk_window_set_transient_for, &
       & GTK_BUTTONS_YES_NO, GTK_MESSAGE_QUESTION, GTK_MESSAGE_OTHER,&
       & GTK_MESSAGE_ERROR, GTK_ICON_SIZE_DIALOG, GTK_MESSAGE_WARNING, &
       & GTK_MESSAGE_INFO, GTK_BUTTONS_NONE, GTK_BUTTONS_OK,&
       & GTK_RESPONSE_OK, GTK_BUTTONS_CLOSE, GTK_RESPONSE_CLOSE,&
       & GTK_BUTTONS_CANCEL, GTK_RESPONSE_CANCEL, GTK_RESPONSE_YES,&
       & GTK_RESPONSE_NO, GTK_BUTTONS_OK_CANCEL, GTK_RESPONSE_NONE,&
       & TRUE, FALSE

  implicit none

contains

  !+
  function hl_gtk_message_dialog_show(message, button_set, title, type, &
       & parent) result(resp)

    integer(kind=c_int) :: resp
    character(len=*), dimension(:), intent(in) :: message
    integer(kind=c_int), intent(in) :: button_set
    character(kind=c_char), dimension(*), intent(in), optional :: title
    integer(kind=c_int), intent(in), optional :: type
    type(c_ptr), intent(in), optional :: parent

    ! A DIY version of the message dialogue, needed because both creators
    ! for the built in one are variadic and so not callable from Fortran.
    !
    ! MESSAGE: string(n): required: The message to display. Since this is
    ! 		a string array, the C_NULL_CHAR terminations are provided
    ! 		internally
    ! BUTTON_SET: integer: required: The set of buttons to display
    ! TITLE: string: optional: Title for the window.
    ! TYPE: c_int: optional: Message type (a GTK_MESSAGE_ value)
    ! PARENT: c_ptr: optional: An optional parent for the dialogue.
    !
    ! The return value is the response code, not the widget.
    !-

    type(c_ptr) :: dialog, content, junk, hb, vb
    integer :: i
    integer(kind=c_int) :: itype

    ! Create the dialog window and make it modal.

    dialog=gtk_dialog_new()
    call gtk_window_set_modal(dialog, TRUE)
    if (present(title)) call gtk_window_set_title(dialog, title)

    if (present(parent)) then
       call gtk_window_set_transient_for(dialog, parent)
       call gtk_window_set_destroy_with_parent(dialog, TRUE)
    end if

    ! Get the content area and put the message in it.
    content = gtk_dialog_get_content_area(dialog)
    if (present(type)) then
       itype = type
    else if (button_set == GTK_BUTTONS_YES_NO) then
       itype = GTK_MESSAGE_QUESTION
    else
       itype = GTK_MESSAGE_OTHER
    end if

    if (itype /= GTK_MESSAGE_OTHER) then
       hb = gtk_hbox_new(FALSE, 0)
       call gtk_box_pack_start(content, hb, TRUE, TRUE, 0)
       select case (itype)
       case (GTK_MESSAGE_ERROR)
          junk = gtk_image_new_from_stock(GTK_STOCK_DIALOG_ERROR, &
               & GTK_ICON_SIZE_DIALOG)
       case (GTK_MESSAGE_WARNING)
          junk = gtk_image_new_from_stock(GTK_STOCK_DIALOG_WARNING, &
               & GTK_ICON_SIZE_DIALOG)
       case (GTK_MESSAGE_INFO)
          junk = gtk_image_new_from_stock(GTK_STOCK_DIALOG_INFO, &
               & GTK_ICON_SIZE_DIALOG)
       case (GTK_MESSAGE_QUESTION)
          junk = gtk_image_new_from_stock(GTK_STOCK_DIALOG_QUESTION, &
               & GTK_ICON_SIZE_DIALOG)
       case default
          junk=C_NULL_PTR
       end select
       if (c_associated(junk)) call gtk_box_pack_start(hb, junk, TRUE, TRUE, 0)
       vb = gtk_vbox_new(FALSE, 0)
       call gtk_box_pack_start(hb, vb, TRUE, TRUE, 0)
    else
       vb = content
    end if

    do i = 1, size(message)
       if (i == 1) then
          junk = gtk_label_new(c_null_char)
          call gtk_label_set_markup(junk, '<b><big>'//trim(message(i))// &
               & '</big></b>'//c_null_char)
       else
          junk = gtk_label_new(trim(message(i))//c_null_char)
       end if
       call gtk_box_pack_start(vb, junk, TRUE, TRUE, 0)
    end do

    select case (button_set)
    case (GTK_BUTTONS_NONE)
    case (GTK_BUTTONS_OK)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_OK, GTK_RESPONSE_OK)
    case (GTK_BUTTONS_CLOSE)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_CLOSE, &
            & GTK_RESPONSE_CLOSE)
    case (GTK_BUTTONS_CANCEL)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_CANCEL, &
            & GTK_RESPONSE_CANCEL)
    case (GTK_BUTTONS_YES_NO)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_YES, GTK_RESPONSE_YES)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_NO, GTK_RESPONSE_NO)
    case (GTK_BUTTONS_OK_CANCEL)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_OK, GTK_RESPONSE_OK)
       junk = gtk_dialog_add_button(dialog, GTK_STOCK_CANCEL, &
            & GTK_RESPONSE_CANCEL)
    case default
       call gtk_widget_destroy(dialog)
       resp = GTK_RESPONSE_NONE
       return
    end select

    call gtk_widget_show_all (dialog)
    resp = gtk_dialog_run(dialog)
    call gtk_widget_destroy(dialog)

  end function hl_gtk_message_dialog_show
end module gtk_hl_dialog
