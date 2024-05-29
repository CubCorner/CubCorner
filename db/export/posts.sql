SELECT id,
       created_at,
       updated_at,
       up_score,
       down_score,
       score,
       source,
       md5,
       rating,
       is_note_locked,
       is_rating_locked,
       is_status_locked,
       is_pending,
       is_flagged,
       is_deleted,
       uploader_id,
       approver_id,
       last_noted_at,
       last_comment_bumped_at,
       fav_count,
       tag_string,
       tag_count,
       tag_count_general,
       tag_count_artist,
       tag_count_character,
       tag_count_copyright,
       file_ext,
       file_size,
       image_width,
       image_height,
       parent_id,
       has_children,
       last_commented_at,
       has_active_children,
       tag_count_meta,
       tag_count_species,
       tag_count_invalid,
       description,
       change_seq,
       tag_count_lore,
       bg_color,
       duration,
       original_tag_string,
       tag_count_voice_actor,
       qtags,
       upload_url
FROM public.posts
